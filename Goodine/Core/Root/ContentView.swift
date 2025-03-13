//
//  ContentView.swift
//  Goodine
//
//  Created by Abhijit Saha on 20/01/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        if businessAuthVM.isLoading {
            ProgressView()
        } else if let restaurant = businessAuthVM.restaurant {
            if subscriptionManager.isSubscribed || restaurant.isSubscribed {
                RestaurantTabView()
            } else {
                SubscriptionView()
            }
        } else {
            MainLoginPage()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BusinessAuthViewModel())
        .environmentObject(SubscriptionManager())
}

