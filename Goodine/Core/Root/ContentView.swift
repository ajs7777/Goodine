//
//  ContentView.swift
//  Goodine
//
//  Created by Abhijit Saha on 20/01/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @EnvironmentObject var userAuthVM : AuthViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    var body: some View {
        Group {
           if businessAuthVM.restaurant != nil {
               LaunchRouterView()
            } else if userAuthVM.userdata != nil {
                UserLaunchRouterView()
            }
            else {
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
        .environmentObject(AuthViewModel())
        .environmentObject(SubscriptionManager())
}
