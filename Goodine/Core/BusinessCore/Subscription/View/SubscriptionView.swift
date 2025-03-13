//
//  SubscriptionView.swift
//  Goodine
//
//  Created by Abhijit Saha on 11/03/25.
//


import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    
    @State private var isYearly = true
    @State private var currentIndex = 0
    @State private var selectedPlan: String = "yearly"
    
    let images: [String] = ["im1", "im2", "im3", "im4" ]
    
    var body: some View {
        VStack {
            
            Spacer()
            
            // Image preview section
            GeometryReader { geo in
                HStack(spacing: -150) {
                    ForEach(images.indices, id: \ .self) { index in
                        Image(images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 170, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 5)
                            .scaleEffect(index == currentIndex ? 1.1 : 0.8)
                            .opacity(index == currentIndex ? 1 : 0.5)
                            .offset(x: CGFloat(index - currentIndex) * 120, y: 0)
                            .animation(.easeInOut(duration: 1.5), value: currentIndex)
                    }
                }
                .frame(width: geo.size.width, height: 200)
            }
            .frame(height: 200)
            .padding(.top, 20)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                    withAnimation {
                        currentIndex = (currentIndex + 1) % images.count
                    }
                }
            }
            
            // Subscription details
            VStack(alignment: .leading, spacing: 16){
                Text("Subscription")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.mainbw)
                    .padding(.top, 20)
                    .offset(y: 25)
                
                Text("Access to premium feature and Easy generate bills.")
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, -10)
                    .offset(y: 30)
                
                // Pricing Toggle
                
                VStack(alignment: .leading) {
                    VStack{
                        Text("Best Offer")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .padding(7)
                            .padding(.bottom, 30)
                            .background(.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .offset(y: 42)
                        Spacer()
                    }
                    
                    HStack() {
                        HStack(spacing: 0){
                            Text("₹")
                                .foregroundStyle(.mainbw)
                                .padding(.bottom, 10)
                            Text("11,999")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.mainbw)
                        }
                        Text("/ Yearly")
                            .font(.footnote)
                            .foregroundColor(.mainbw.opacity(0.5))
                        Spacer()
                        if isYearly {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.vertical, 1)
                    .padding()
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .onTapGesture {
                        isYearly = true
                        selectedPlan = "yearly"
                    }
                    
                }
                
                HStack {
                    HStack(spacing: 0){
                        Text("₹")
                            .foregroundStyle(.mainbw)
                            .padding(.bottom, 10)
                        Text("1,199")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.mainbw)
                    }
                    Text("/ Monthly")
                        .font(.footnote)
                        .foregroundColor(.mainbw.opacity(0.5))
                    Spacer()
                    if !isYearly {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 1)
                .padding()
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .onTapGesture {
                    isYearly = false
                    selectedPlan = "monthly"
                }
                
            }
            .padding(.horizontal, 50)
            .padding(.top, 10)
            
            // Additional Features
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "checkmark")
                        .foregroundColor(.orange)
                        .fontWeight(.bold)
                    Text("Select Tables and particular seats")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                HStack {
                    Image(systemName: "checkmark")
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Easily Generate bills And track payments")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 10)
            
            Spacer()
            // Free Trial Button
            Button(action: {
                Task {
                    try? await subscriptionManager.purchaseSubscription(type: selectedPlan)
                    await businessAuthVM.updateSubscription(type: selectedPlan)
                }
            }) {
                Text("Buy Premium")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 50)
            .padding(.top, 20)
            
            // Terms and Privacy
            HStack {
                Text("Terms of use")
                    .underline()
                Spacer()
                Text("Privacy policy")
                    .underline()
                
            }
            .foregroundColor(.black.opacity(0.2))
            .font(.footnote)
            .fontWeight(.bold)
            .padding(.horizontal, 100)
            .padding(.vertical, 8)
            
            Spacer()
        }
        .frame(maxWidth : 600)
        .clipShape(Rectangle()                                                                         )
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(BusinessAuthViewModel())  // 🔥 Fix: Add environment objects
        .environmentObject(SubscriptionManager())
}
