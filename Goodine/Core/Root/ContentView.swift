//
//  ContentView.swift
//  Goodine
//
//  Created by Abhijit Saha on 20/01/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @StateObject var subscriptionManager = SubscriptionManager()

    var body: some View {
        if businessAuthVM.restaurant != nil {
            if subscriptionManager.isSubscribed {
                RestaurantTabView()
            } else {
                SubscriptionView()
            }
        } else {
            LoginWithNumberView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BusinessAuthViewModel())
}
