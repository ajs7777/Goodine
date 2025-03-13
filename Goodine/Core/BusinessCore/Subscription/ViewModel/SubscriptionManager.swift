//
//  SubscriptionManager.swift
//  Goodine
//
//  Created by Abhijit Saha on 11/03/25.
//


import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isSubscribed = false
    @Published var subscriptionType: String? // "monthly" or "yearly"
    
    let monthlyProductID = "com.goodine.subscription.1month" // Update with real App Store product IDs
    let yearlyProductID = "com.goodine.subscription.12month"
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = Task {
            for await result in Transaction.updates {
                await self.processTransaction(result)
            }
        }
    }
    
    /// Fetches the latest subscription status
    func fetchSubscriptionStatus() async {
        do {
            try await AppStore.sync() // Ensures latest transactions are fetched
            
            for await transaction in Transaction.currentEntitlements {
                await processTransaction(transaction)  // ✅ Ensures transactions are processed
            }
        } catch {
            print("Error syncing subscriptions: \(error.localizedDescription)")
        }
    }

    /// Handles purchasing of subscription
    func purchaseSubscription(type: String) async throws {
        let productID = type == "monthly" ? monthlyProductID : yearlyProductID
        guard let product = try await Product.products(for: [productID]).first else { return }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            await processTransaction(verification)
            await fetchSubscriptionStatus()  // ✅ Immediately update subscription status
        case .pending, .userCancelled:
            break
        @unknown default:
            break
        }
    }
    
    /// Processes transactions and updates the subscription status
    private func processTransaction(_ verification: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verification else { return }
        
        await MainActor.run {
            self.isSubscribed = true
            self.subscriptionType = transaction.productID == self.monthlyProductID ? "monthly" : "yearly"
        }
        
        await transaction.finish()
    }
}


