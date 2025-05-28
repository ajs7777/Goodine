//
//  LaunchScreenView.swift
//  Goodine
//
//  Created by Abhijit Saha on 13/03/25.
//


import SwiftUI

struct LaunchScreenView: View {
    
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @EnvironmentObject var userAuthVM: AuthViewModel
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var nearbyVM: NearbyRestaurantsViewModel
    @EnvironmentObject var locationVM: LocationViewModel
    
    @State private var isActive = false
    
    @State private var isAnimating = false
    @State private var showBoltIcon = false
    @State private var boltScale: CGFloat = 1.5
    
    var body: some View {
        if isActive {
            ContentView()
                .transition(.opacity)
                .environmentObject(businessAuthVM)
                .environmentObject(userAuthVM)
                .environmentObject(subscriptionManager)
                .environmentObject(nearbyVM)
                .environmentObject(locationVM)
        } else {
            ZStack {
                Color.mainInvert.edgesIgnoringSafeArea(.all)
                
                // Location Icon (appears first)
                Image("locationIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .scaleEffect(isAnimating ? 1.3 : 0)
                    .rotationEffect(Angle(degrees: isAnimating ? 0 : -10))
                    .animation(.easeOut(duration: 0.4), value: isAnimating)
                
                // Bolt Icon (appears from top to bottom)
                Image("boltIcon")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(.mainInvert)
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .opacity(showBoltIcon ? 1 : 0)
                    .scaleEffect(boltScale)
                    .offset(y: showBoltIcon ? -30 : -300)
                    .animation(.easeInOut(duration: 0.2), value: showBoltIcon)
                    .animation(.easeInOut(duration: 0.8), value: boltScale)
            }
            .onAppear {
                isAnimating = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showBoltIcon = true
                    boltScale = 2.5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    boltScale = 30
                    
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    isAnimating = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.99) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
