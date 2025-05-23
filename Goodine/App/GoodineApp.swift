//
//  GoodineApp.swift
//  Goodine
//
//  Created by Abhijit Saha on 20/01/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct GoodineApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var businessAuthVM = BusinessAuthViewModel()
    @StateObject var userAuthVM = AuthViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager.shared    
    @StateObject private var nearbyVM = NearbyRestaurantsViewModel()
    @StateObject var locationVM = LocationViewModel()

    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environmentObject(BusinessAuthViewModel())
                .environmentObject(AuthViewModel())
                .environmentObject(subscriptionManager)
                .environmentObject(nearbyVM)
                .environmentObject(locationVM)
        }
    }
}
