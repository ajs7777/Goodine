import SwiftUI
import StoreKit
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isProcessing = false
    @Published var isSubscribed = false
    @Published var subscribedProductID: String? = nil
    static let shared = SubscriptionManager()
    
    let productIDs = ["com.goodine.subscription.1month", "com.goodine.subscription.12month"]
    
    init() {
        Task {
            await fetchProducts()
            await checkSubscriptionStatus()
            listenForTransactions()
        }
        
    }
    
    /// Fetch products from App Store
    func fetchProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIDs)
            DispatchQueue.main.async {
                self.products = storeProducts.sorted { $0.price < $1.price }
            }
        } catch {
            print("❌ Failed to fetch products: \(error)")
        }
    }
    
    /// Listen for transactions
    private func listenForTransactions() {
        Task {
            for await transactionResult in Transaction.updates {
                await handleTransactions([transactionResult])
            }
        }
    }
    
    /// Function to process transactions
    func handleTransactions(_ transactions: [VerificationResult<StoreKit.Transaction>]) async {
        for verificationResult in transactions {
            switch verificationResult {
            case .verified(let transaction):
                guard let userID = Auth.auth().currentUser?.uid,
                      let businessUserID = await fetchBusinessUserID() else { continue }
                
                let expirationDate = Calendar.current.date(
                    byAdding: transaction.productID.contains("1month") ? .month : .year,
                    value: 1,
                    to: transaction.purchaseDate
                )!
                
                DispatchQueue.main.async {
                    self.isSubscribed = true
                    self.subscribedProductID = transaction.productID
                }

                
                await storeSubscriptionDetails(userID: userID, businessUserID: businessUserID, productID: transaction.productID, expirationDate: expirationDate)
                
                await transaction.finish()
            case .unverified(_, let error):
                print("❌ Unverified transaction: \(error)")
            }
        }
    }
    
    /// Purchase a subscription
    func purchaseSubscription(product: Product) async {
        guard let userID = Auth.auth().currentUser?.uid,
              let businessUserID = await fetchBusinessUserID() else { return }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    let expirationDate = Calendar.current.date(
                        byAdding: product.id.contains("1month") ? .month : .year,
                        value: 1,
                        to: transaction.purchaseDate
                    )!
                    
                    DispatchQueue.main.async {
                        self.isSubscribed = true
                        self.subscribedProductID = product.id
                    }
                    
                    await storeSubscriptionDetails(userID: userID, businessUserID: businessUserID, productID: product.id, expirationDate: expirationDate)
                    await transaction.finish()
                    
                case .unverified(_, let error):
                    print("❌ Unverified transaction: \(error)")
                }
            case .userCancelled:
                print("⚠️ Purchase cancelled by user.")
            case .pending:
                print("⏳ Purchase pending approval.")
            @unknown default:
                print("❓ Unknown purchase result.")
            }
        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }
    
    /// Find the business user ID associated with the logged-in user
    private func fetchBusinessUserID() async -> String? {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in")
            return nil
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("business_users").whereField("id", isEqualTo: userID)
        
        do {
            let snapshot = try await userRef.getDocuments()
            if let document = snapshot.documents.first {
                print("✅ Found Business User ID: \(document.documentID)")
                return document.documentID
            } else {
                print("❌ No business user found for this user")
                return nil
            }
        } catch {
            print("❌ Error fetching business user ID: \(error)")
            return nil
        }
    }
    
    /// Store subscription details in Firestore
    func storeSubscriptionDetails(userID: String, businessUserID: String, productID: String, expirationDate: Date) async {
        let db = Firestore.firestore()
        
        let subscriptionData: [String: Any] = [
            "userID": userID,
            "productID": productID,
            "purchaseDate": Timestamp(date: Date()),
            "expirationDate": Timestamp(date: expirationDate),
            "isActive": true
        ]
        
        do {
            try await db.collection("business_users")
                .document(businessUserID)
                .collection("subscriptions")
                .document(userID)
                .setData(subscriptionData)
            
            DispatchQueue.main.async {
                self.isSubscribed = true
            }
        } catch {
            print("❌ Error saving subscription: \(error)")
        }
    }
    
    /// Check if the user has an active subscription
    func checkSubscriptionStatus() async {
        guard let userID = Auth.auth().currentUser?.uid,
              let businessUserID = await fetchBusinessUserID() else { return }
        
        let db = Firestore.firestore()
        let docRef = db.collection("business_users")
            .document(businessUserID)
            .collection("subscriptions")
            .document(userID)
        
        do {
            let document = try await docRef.getDocument()
            if let data = document.data(),
               let expirationTimestamp = data["expirationDate"] as? Timestamp,
               let productID = data["productID"] as? String {
                
                let expirationDate = expirationTimestamp.dateValue()
                let isActive = expirationDate > Date()
                
                DispatchQueue.main.async {
                    self.isSubscribed = isActive
                    self.subscribedProductID = isActive ? productID : nil
                }
                
                if !isActive {
                    await updateSubscriptionStatus(userID: userID, businessUserID: businessUserID, isActive: false)
                }
            }

        } catch {
            print("❌ Error checking subscription: \(error)")
        }
    }
    
    /// Update expired subscription
    func updateSubscriptionStatus(userID: String, businessUserID: String, isActive: Bool) async {
        let db = Firestore.firestore()
        let docRef = db.collection("business_users")
            .document(businessUserID)
            .collection("subscriptions")
            .document(userID)
        
        await MainActor.run {
            docRef.updateData(["isActive": isActive]) { error in
                if let error = error {
                    print("❌ Error updating subscription status: \(error.localizedDescription)")
                } else {
                    print("✅ Subscription status updated successfully: \(isActive)")
                }
            }
        }
    }
    
    /// Restore purchases
    func restorePurchases() async {
        do {
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    if productIDs.contains(transaction.productID) {
                        DispatchQueue.main.async {
                            self.isSubscribed = true
                            self.subscribedProductID = transaction.productID
                        }
                        return
                    }
                case .unverified(_, let error):
                    print("❌ Unverified restored purchase: \(error.localizedDescription)")
                }
            }
        }
        
        DispatchQueue.main.async {
            self.isSubscribed = false
        }
    }
    
    /// Receipt Validation
    func validateReceipt() async {
        guard let receiptString = await getReceiptData() else { return }
        
        let requestBody = [
            "receipt_data": receiptString,
            "password": "your_shared_secret"
        ]
        
        guard let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? Int, status == 0 {
                print("✅ Receipt is valid.")
            } else {
                print("❌ Invalid receipt.")
            }
        } catch {
            print("❌ Error validating receipt: \(error)")
        }
    }
    
    func getReceiptData() async -> String? {
        do {
            let verificationResult = try await AppTransaction.shared
            
            switch verificationResult {
            case .verified(let appTransaction):
                // Extract necessary fields
                let receiptDict: [String: Any] = [
                    "originalPurchaseDate": appTransaction.originalPurchaseDate.timeIntervalSince1970,
                    "bundleID": appTransaction.bundleID,
                    "environment": appTransaction.environment.rawValue
                ]
                
                // Convert dictionary to JSON data
                let jsonData = try JSONSerialization.data(withJSONObject: receiptDict, options: [])
                
                return jsonData.base64EncodedString()
                
            case .unverified(_, let error):
                print("❌ Receipt is unverified: \(error)")
                return nil
            }
        } catch {
            print("❌ Failed to fetch receipt data: \(error)")
            return nil
        }
    }
    
}
