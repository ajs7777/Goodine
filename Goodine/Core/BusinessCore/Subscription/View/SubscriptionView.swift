//
//  SubscriptionView.swift
//  Goodine
//
//  Created by Abhijit Saha on 11/03/25.
//


import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @StateObject var subscriptionManager = SubscriptionManager()
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel

    var body: some View {
        HStack{
        Button("Subscribe for ₹1199/month") {
            Task {
                try? await SubscriptionManager.shared.purchaseSubscription(type: "monthly")
                await businessAuthVM.updateSubscription(type: "monthly")
            }
        }
        
        Button("Subscribe for ₹11,999/year") {
            Task {
                try? await SubscriptionManager.shared.purchaseSubscription(type: "yearly")
                await businessAuthVM.updateSubscription(type: "yearly")
            }
        }
        
    }
        .font(.title)

    }
}


#Preview {
    SubscriptionView()
}
