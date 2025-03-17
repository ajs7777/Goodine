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
    @State private var selectedProductID: String?
    
    let images: [String] = ["im1", "im2", "im3", "im4" ]
    
    var body: some View {
        NavigationStack {
            VStack {
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
                VStack(alignment: .leading) {
                    Text("Subscription")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(.mainbw)
                    
                    Text("Access premium restaurant management tools with a monthly or yearly subscription.")
                        .fontWeight(.medium)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 50)
                .offset(y: 42)
               

                // Subscription details
                VStack(alignment: .leading, spacing: 16){
                    
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
                            selectedProductID = "com.goodine.subscription.12month"
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
                        selectedProductID = "com.goodine.subscription.1month"
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
                .padding(.vertical, 10)
                   
                Button(action: {
                    Task {
                        if let productID = selectedProductID,
                           let product = subscriptionManager.products.first(where: { $0.id == productID }) {
                            await subscriptionManager.purchaseSubscription(product: product)
                        } else {
                            print("❌ No product selected")
                        }
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
                
                // Terms and Privacy
                HStack {
                    Link("Terms of Use", destination: URL(string: "https://sites.google.com/view/goodine-terms-of-use")!)
                            .underline()
                    Spacer()
                    Link("Privacy Policy", destination: URL(string: "https://sites.google.com/view/goodine-privacy-policy")!)
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
            .clipShape(Rectangle())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        businessAuthVM.signOut()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(.mainbw)
                            .padding(.trailing)
                    }
                    
                }
            }
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(BusinessAuthViewModel())
        .environmentObject(SubscriptionManager())
}
