import SwiftUI
import Kingfisher
import FirebaseFirestore

struct OrderSummaryView: View {
    @Binding var selectedItems: [String: Int]
    let menuItems: [MenuItem]
    let restaurant: Restaurant
    let currencySymbol: String
    var reservation: Reservation
    let onConfirm: () -> Void
    
    @State private var showPaymentSheet = false
    @State private var showSuccessAlert = false
    @State private var showUPIConfirmation = false
    @State private var upiOrderId = ""

    @AppStorage("selectedPaymentApp") private var selectedAppRaw: String = ""
    @State private var showUPIAppSheet = false

    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Order Summary")
                    .font(.title2.bold())
                    .padding(.top)
                
                ScrollView {
                    ForEach(menuItems.filter { selectedItems[$0.id] != nil }) { item in
                        let quantity = selectedItems[item.id] ?? 0
                        MenuItemRowView(
                            item: item,
                            quantity: quantity,
                            currencySymbol: currencySymbol,
                            onIncrement: {
                                selectedItems[item.id] = quantity + 1
                            },
                            onDecrement: {
                                if quantity > 1 {
                                    selectedItems[item.id] = quantity - 1
                                } else {
                                    selectedItems.removeValue(forKey: item.id)
                                }
                            }
                        )
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Subtotal:")
                        Spacer()
                        Text("\(currencySymbol)\(calculateTotal(), specifier: "%.2f")")
                    }
                    
                    HStack {
                        Text("Platform Fee:")
                        Spacer()
                        Text("\(currencySymbol)3.00")
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total:")
                            .font(.title3.bold())
                        Spacer()
                        Text("\(currencySymbol)\(calculateTotal() + 3.0, specifier: "%.2f")")
                            .font(.title3.bold())
                    }
                }
                .font(.subheadline)
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    
                    Button("Pay with UPI") {
                        showUPIAppSheet = true
                    }
                    .goodineButtonStyle(.mainbw)
                    .sheet(isPresented: $showUPIAppSheet) {
                        PaymentSelectionSheet(isPresented: $showUPIAppSheet)
                    }
                    if let selectedApp = PaymentApp(rawValue: selectedAppRaw), selectedApp != .any {
                        Button("Proceed with \(selectedApp.rawValue)") {
                            launchUPIPayment(using: selectedApp)
                        }
                        .goodineButtonStyle(.mainbw)
                    }

                }
                .alert(isPresented: $showSuccessAlert) {
                    Alert(
                        title: Text("Payment Successful"),
                        message: Text("Your order has been placed."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .padding()
        }
        // Confirmation Sheet for UPI
        .sheet(isPresented: $showUPIConfirmation) {
            VStack(spacing: 20) {
                Text("Confirm Payment")
                    .font(.title2.bold())
                Text("Did you complete the payment in your UPI app?")
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Button("No") {
                        showUPIConfirmation = false
                    }
                    .foregroundColor(.red)
                    
                    Button("Yes, I Paid") {
                        markOrderPaid(orderId: upiOrderId)
                        showUPIConfirmation = false
                        showSuccessAlert = true
                        onConfirm()
                    }
                    .foregroundColor(.green)
                }
            }
            .padding()
        }
    }
    
    private func calculateTotal() -> Double {
        menuItems.reduce(0) { result, item in
            let quantity = selectedItems[item.id] ?? 0
            return result + Double(quantity) * Double(item.foodPrice)
        }
    }
    
    private func launchUPIPayment(using app: PaymentApp) {
        let upiID = "Q828806495@ybl" // Your actual UPI ID
        let name = "Fry Day Bite"
        let transactionNote = "Food Order"
        let currency = "INR"
        let amount = calculateTotal() + 3.0
        let orderId = "ORD\(Int(Date().timeIntervalSince1970))"
        upiOrderId = orderId

        createPendingOrderInFirestore(orderId: orderId, amount: amount)

        var urlStr = "upi://pay?pa=\(upiID)&pn=\(name)&tn=\(transactionNote)&am=\(String(format: "%.2f", amount))&cu=\(currency)&tr=\(orderId)"

        // Use scheme prefix for selected app
        if app != .any {
            urlStr = "\(app.schemePrefix)://pay?pa=\(upiID)&pn=\(name)&tn=\(transactionNote)&am=\(String(format: "%.2f", amount))&cu=\(currency)&tr=\(orderId)"
        }

        if let encoded = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            UIApplication.shared.open(url) { success in
                if success {
                    showUPIConfirmation = true
                } else {
                    print("Could not open UPI app")
                }
            }
        }
    }

    
    private func createPendingOrderInFirestore(orderId: String, amount: Double) {
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "orderId": orderId,
            "restaurantId": restaurant.id,
            "amount": amount,
            "status": "pending",
            "items": selectedItems,
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("orders").document(orderId).setData(data) { error in
            if let error = error {
                print("Error saving order: \(error.localizedDescription)")
            } else {
                print("Order created with status pending")
            }
        }
    }

    private func markOrderPaid(orderId: String) {
        let db = Firestore.firestore()
        db.collection("orders").document(orderId).updateData(["status": "paid"]) { error in
            if let error = error {
                print("Error updating payment status: \(error.localizedDescription)")
            } else {
                print("Order marked as paid")
            }
        }
    }
}


struct MenuItemRowView: View {
    let item: MenuItem
    let quantity: Int
    let currencySymbol: String
    var onIncrement: () -> Void
    var onDecrement: () -> Void
    
    var body: some View {
        let totalItemPrice = Double(quantity) * Double(item.foodPrice)
        
        HStack(spacing: 12) {
            if let imageUrl = item.foodImage, let url = URL(string: imageUrl) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding(15)
                    .background(.mainbw.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.foodname)
                    .fontWeight(.semibold)
                
                Text("\(currencySymbol)\(totalItemPrice, specifier: "%.2f")")
                    .font(.subheadline.bold())
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onDecrement) {
                    Image(systemName: "minus")
                        .foregroundStyle(.red)
                        .font(.system(size: 12, weight: .heavy))
                        .frame(width: 20, height: 20)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                
                Text("\(quantity)")
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .frame(width: 20)
                
                Button(action: onIncrement) {
                    Image(systemName: "plus")
                        .foregroundStyle(.mainbw)
                        .font(.system(size: 12, weight: .heavy))
                        .frame(width: 20, height: 20)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(6)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 1)
        }
        .padding(.vertical, 4)
    }
}
