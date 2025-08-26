import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    @State private var currentIndex = 0
    let images: [String] = ["im1", "im2", "im3", "im4" ]
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
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
                    timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                        withAnimation {
                            currentIndex = (currentIndex + 1) % images.count
                        }
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                    timer = nil
                }
                Text("Choose Your Subscription")
                    .font(.title2)
                    .bold()
                    .padding(10)
                
                
                if subscriptionManager.products.isEmpty {
                    ProgressView("Loading subscriptions...")
                        .font(.footnote)
                } else {
                    ForEach(subscriptionManager.products, id: \.id) { product in
                        SubscriptionRow(product: product)
                    }
                }
                                
                Button(action: {
                    Task { await subscriptionManager.restorePurchases() }
                }) {
                    Text("Restore Purchases")
                        .foregroundColor(.orange)
                        .font(.caption)
                        .padding(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
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
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button{
                        dismiss()
                    }label:{
                        Image(systemName:"xmark")
                            .foregroundColor(.mainbw)
                            .fontWeight(.heavy)
                            .padding(.trailing, 5)
                    }
                }
            })
            .padding()
         
            
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
                Task {
                    await subscriptionManager.purchaseSubscription(product: product)
                    if subscriptionManager.products.isEmpty {
                        await subscriptionManager.fetchProducts()
                    }
                }
            }) {
                Text(subscriptionManager.subscribedProductID == product.id ? "Subscribed" : "Subscribe")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(subscriptionManager.subscribedProductID == product.id ? .gray : Color.orange)
                    .cornerRadius(10)
            }
            .disabled(subscriptionManager.subscribedProductID == product.id)

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
