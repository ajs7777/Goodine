//
//  LaunchRouterView.swift
//  Goodine
//
//  Created by Abhijit Saha on 02/05/25.
//

import SwiftUI
import CoreLocation

struct LaunchRouterView: View {
    @State private var showLocationScreen: Bool = false
    
    var body: some View {
        Group {
            if showLocationScreen {
                RestaurantLocation(onLocationAllowed: {
                    showLocationScreen = false
                })
            } else {
                RestaurantTabView()
            }
        }
        .onAppear {
            // Check if location permission has been granted
            if UserDefaults.standard.bool(forKey: "locationPermissionGranted") {
                // If location is allowed, skip the location screen
                showLocationScreen = false
            } else {
                // Show location screen if the user hasn't allowed location permission
                showLocationScreen = true
            }
        }
    }
}
