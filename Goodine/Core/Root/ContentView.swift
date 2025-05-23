//
//  ContentView.swift
//  Goodine
//
//  Created by Abhijit Saha on 20/01/25.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @EnvironmentObject var userAuthVM: AuthViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @StateObject var userLocationManager = UserLocationManager()

    @State private var isCheckingAuth = true
    @State private var isUserAuthenticated = false
    @State private var isBusinessAuthenticated = false

    var body: some View {
        Group {
            if isCheckingAuth {
                ProgressView("Loading...")
            } else if isUserAuthenticated {
                UserLaunchRouterView()
                    .environmentObject(userLocationManager)
            } else if isBusinessAuthenticated {
                LaunchRouterView()
            } else {
                MainLoginPage()
            }
        }
        .onAppear {
            Task {
                async let userTask: () = userAuthVM.fetchUserData()
                async let businessTask: () = businessAuthVM.checkUserAuthentication()
                async let subTask: () = subscriptionManager.checkSubscriptionStatus()

                let (user: (), business: (), _) = await (userTask, businessTask, subTask)

                // After the data loads, set flags
                isUserAuthenticated = userAuthVM.userdata != nil
                isBusinessAuthenticated = businessAuthVM.restaurant != nil
                isCheckingAuth = false
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
