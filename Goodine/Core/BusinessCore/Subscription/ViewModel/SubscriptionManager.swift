//
//  SubscriptionManager.swift
//  Goodine
//
//  Created by Abhijit Saha on 11/03/25.
//


import SwiftUI
import StoreKit
import FirebaseFirestore
import FirebaseAuth

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isProcessing = false
    @Published var isSubscribed = false  // Tracks active subscription status
    static let shared = SubscriptionManager()
    
    let productIDs = ["com.goodine.subscription.1month", "com.goodine.subscription.12month"]
    
    init() {
        Task {
            await fetchProducts()
            await checkSubscriptionStatus()
        }
        listenForTransactions()
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
    
    /// Purchase a subscription
    /// Purchase a subscription
    func purchaseSubscription(product: Product) async {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No logged-in user found")
            return
        }
        
        guard let businessUserID = await fetchBusinessUserID() else {
            print("❌ Business User ID not found")
            return
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    print("✅ Purchase successful: \(transaction.productID)")
                    
                    let expirationDate = Calendar.current.date(
                        byAdding: product.id.contains("1month") ? .month : .year,
                        value: 1,
                        to: transaction.purchaseDate
                    )!
                    
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
    
    /// Function to process transactions
    func handleTransactions(_ transactions: [VerificationResult<StoreKit.Transaction>]) async {
        for verificationResult in transactions {
            switch verificationResult {
            case .verified(let verifiedTransaction):
                print("✅ Verified transaction: \(verifiedTransaction.productID)")
                
                guard let userID = Auth.auth().currentUser?.uid else {
                    print("❌ Missing user ID")
                    continue
                }
                
                guard let businessUserID = await fetchBusinessUserID() else {
                    print("❌ Missing business user ID")
                    continue
                }
                
                let expirationDate = Calendar.current.date(
                    byAdding: verifiedTransaction.productID.contains("1month") ? .month : .year,
                    value: 1,
                    to: verifiedTransaction.purchaseDate
                )!
                
                await storeSubscriptionDetails(
                    userID: userID,
                    businessUserID: businessUserID,
                    productID: verifiedTransaction.productID,
                    expirationDate: expirationDate
                )
                
                await verifiedTransaction.finish() // ✅ Mark transaction as complete
            
            case .unverified(_, let error):
                print("❌ Unverified transaction: \(error.localizedDescription)")
            }
        }
    }


    
    /// Start listening for transaction updates

    private func listenForTransactions() {
          Task {
              for await transactionResult in Transaction.updates {
                  await handleTransactions([transactionResult])
              }
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
            let docRef = db.collection("business_users")
                .document(businessUserID)
                .collection("subscriptions")
                .document(userID)  // Using userID as the document ID
            
            try await docRef.setData(subscriptionData)
            print("✅ Subscription saved successfully!")
            
            DispatchQueue.main.async {
                self.isSubscribed = true
            }
        } catch {
            print("❌ Error saving subscription: \(error)")
        }
    }
    
    /// Check if the user has an active subscription
    func checkSubscriptionStatus() async {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No logged-in user")
            DispatchQueue.main.async {
                self.isSubscribed = false
            }
            return
        }
        
        guard let businessUserID = await fetchBusinessUserID() else {
            print("❌ Business User ID not found")
            return
        }
        
        let db = Firestore.firestore()
        let docRef = db.collection("business_users")
            .document(businessUserID)
            .collection("subscriptions")
            .document(userID)
        
        do {
            let document = try await docRef.getDocument()
            if let data = document.data(),
               let expirationTimestamp = data["expirationDate"] as? Timestamp {
                
                let expirationDate = expirationTimestamp.dateValue()
                let isActive = expirationDate > Date()  // Check if expired
                
                DispatchQueue.main.async {
                    self.isSubscribed = isActive
                }
                
                print("✅ Subscription status checked. Active: \(isActive)")
                
                // If expired, update Firestore
                if !isActive {
                    await updateSubscriptionStatus(userID: userID, businessUserID: businessUserID, isActive: false)
                }
            } else {
                print("❌ No subscription data found")
                DispatchQueue.main.async {
                    self.isSubscribed = false
                }
            }
        } catch {
            print("❌ Error checking subscription: \(error)")
        }
    }
    
    /// Update subscription status when expired
    func updateSubscriptionStatus(userID: String, businessUserID: String, isActive: Bool) async {
        let db = Firestore.firestore()
        let docRef = db.collection("business_users")
            .document(businessUserID)
            .collection("subscriptions")
            .document(userID)
        
        do {
            DispatchQueue.main.async {
                docRef.updateData(["isActive": isActive]) { error in
                    if let error = error {
                        print("❌ Error updating subscription status: \(error)")
                    } else {
                        print("✅ Subscription status updated: \(isActive)")
                    }
                }
            }
        }
    }
    
    /// Restore purchases (Re-check Firestore to verify active status)
    func restorePurchases() async {
        do {
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    if productIDs.contains(transaction.productID) {
                        DispatchQueue.main.async {
                            self.isSubscribed = true
                        }
                        print("✅ Restored active subscription: \(transaction.productID)")
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

}


