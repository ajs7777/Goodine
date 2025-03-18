import SwiftUI
import StoreKit

struct SubscriptionView: View {
    
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @State private var currentIndex = 0
    let images: [String] = ["im1", "im2", "im3", "im4" ]
    
    var body: some View {
        VStack(spacing: 20) {
            
            GeometryReader { geo in
                HStack(spacing: -200) {
                    ForEach(images.indices, id: \ .self) { index in
                        Image(images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 170, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 5)
                            .scaleEffect(index == currentIndex ? 0.8 : 0.5)
                            .opacity(index == currentIndex ? 1 : 0.5)
                            .offset(x: CGFloat(index - currentIndex) * 120, y: 0)
                            .animation(.easeInOut(duration: 1.5), value: currentIndex)
                    }
                }
                .frame(width: geo.size.width, height: 60)
            }
            .frame(height: 100)
            .padding(.top, 20)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                    withAnimation {
                        currentIndex = (currentIndex + 1) % images.count
                    }
                }
            }
            Text("Choose Your Subscription")
                .font(.title2)
                .bold()
                .padding(10)
            
            
            if subscriptionManager.products.isEmpty {
                ProgressView("Loading subscriptions...")
            } else {
                ForEach(subscriptionManager.products, id: \.id) { product in
                    SubscriptionRow(product: product)
                }
            }
            
            if subscriptionManager.isSubscribed {
                Text("✅ You are subscribed")
                    .foregroundColor(.green)
                    .bold()
            }
            
            Button(action: {
                Task { await subscriptionManager.restorePurchases() }
            }) {
                Text("Restore Purchases")
                    .foregroundColor(.orange)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange, lineWidth: 2)
                    )
            }
            .padding(5)
            
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
            .padding(.horizontal, 60)
            .padding(.vertical, 8)
        }
        .padding()
        .onAppear {
            Task { await subscriptionManager.fetchProducts() }
        }
    }
}

struct SubscriptionRow: View {
    let product: Product
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.title2)
                        .fontWeight(.heavy)
                    Text(product.description)
                        .font(.footnote)
                }
                Spacer()
                Text(product.price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                    .font(.title3)
                    .fontWeight(.heavy)
            }
            .padding(10)
            
            Button(action: {
                Task { await subscriptionManager.purchaseSubscription(product: product) }
            }) {
                Text("Subscribe")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 2))
        .padding(.horizontal)
    }
}

#Preview{
    SubscriptionView()
        .environmentObject(SubscriptionManager())
}
