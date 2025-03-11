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
    
    let monthlyProductID = "com.yourapp.subscription.monthly" // Set your real product IDs from App Store
    let yearlyProductID = "com.yourapp.subscription.yearly"
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = Task {
            for await result in Transaction.updates {
                await self.processTransaction(result)
            }
        }
    }
    

    func fetchSubscriptionStatus() async {
        do {
            try await AppStore.sync() // Ensures the latest transactions are fetched
            
            for await transaction in Transaction.currentEntitlements {
                await processTransaction(transaction)
            }
        } catch {
            print("Error syncing subscriptions: \(error.localizedDescription)")
        }
    }

    
    func purchaseSubscription(type: String) async throws {
        let productID = type == "monthly" ? monthlyProductID : yearlyProductID
        guard let product = try await Product.products(for: [productID]).first else { return }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            await processTransaction(verification)
        case .pending, .userCancelled:
            break
        @unknown default:
            break
        }
    }
    
    private func processTransaction(_ verification: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verification else { return }
        
        DispatchQueue.main.async {
            self.isSubscribed = true
            self.subscriptionType = transaction.productID == self.monthlyProductID ? "monthly" : "yearly"
        }
        
        await transaction.finish()
    }
}

