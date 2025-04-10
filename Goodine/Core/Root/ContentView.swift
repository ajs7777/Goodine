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
        Group {
            if businessAuthVM.isLoading {
                ProgressView()
            } else if businessAuthVM.restaurant != nil {
                    RestaurantTabView()
            } else {
                MainLoginPage()
            }
        }
        .onAppear {
            Task {
                await businessAuthVM.checkUserAuthentication()
                await subscriptionManager.checkSubscriptionStatus()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BusinessAuthViewModel())
        .environmentObject(SubscriptionManager())
}


