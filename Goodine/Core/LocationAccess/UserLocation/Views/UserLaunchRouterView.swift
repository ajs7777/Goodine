//
//  UserLaunchRouterView.swift
//  Goodine
//
//  Created by Abhijit Saha on 05/05/25.
//


import SwiftUI
import CoreLocation

struct UserLaunchRouterView: View {
    @State private var showLocationScreen: Bool = false
    
    var body: some View {
        Group {
            if showLocationScreen {
                UserLocation(onLocationAllowed: {
                    showLocationScreen = false
                })
            } else {
                MainTabView()
            }
        }
        .onAppear {
            // Check if location permission has been granted
            if UserDefaults.standard.bool(forKey: "locationPermissionAllowed") {
                // If location is allowed, skip the location screen
                showLocationScreen = false
            } else {
                // Show location screen if the user hasn't allowed location permission
                showLocationScreen = true
            }
        }
    }
}
