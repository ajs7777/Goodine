//
//  UserLaunchRouterView.swift
//  Goodine
//
//  Created by Abhijit Saha on 05/05/25.
//


import SwiftUI
import CoreLocation

struct UserLaunchRouterView: View {
    @EnvironmentObject var userLocationManager: UserLocationManager
    @State private var showLocationScreen: Bool? = nil

    var body: some View {
        Group {
            if showLocationScreen == nil {
                ProgressView("Preparing...")
            } else if showLocationScreen == true {
                UserLocation {
                    UserDefaults.standard.set(true, forKey: "locationPermissionAllowed")
                    showLocationScreen = false
                }
            } else {
                MainTabView() // Always navigate to `MainTabView()` if location permission is granted.
            }
        }
        .onAppear {
            if UserDefaults.standard.bool(forKey: "locationPermissionAllowed") {
                // If location permission is allowed, fetch the user's location
                userLocationManager.requestLocation()
                showLocationScreen = false
            } else {
                // Show the location permission screen
                showLocationScreen = true
            }
        }
    }
}

