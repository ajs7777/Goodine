
import SwiftUI

struct ShowOrdersView: View {
    
    @EnvironmentObject var orderVM : OrdersViewModel
    @EnvironmentObject var tableVM : TableViewModel
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    
    let reservationId: String
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Calculate total order price
    private var totalPrice: Double {
        let orderTotal = orderVM.orders.reduce(0) { total, order in
            total + order.items.values.reduce(0) { subtotal, item in
                subtotal + (item.price * Double(item.quantity))
            }
        }
        return orderTotal + 3.0 // Add platform fee
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                if let reservation = tableVM.reservations.first(where: { $0.id == reservationId }) {
                    
                    ForEach(reservation.tables, id: \.self) { tableNumber in
                        if let seatArray = reservation.seats[tableNumber], seatArray.contains(true) {
                            let selectedSeatCount = seatArray.filter { $0 }.count
                            HStack {
                                Text("Table \(tableNumber) - \(selectedSeatCount)")
                                Image(systemName: "person.fill")
                            }
                        }
                    }
                    
                    Divider()
                    
                    if orderVM.orders.isEmpty {
                        Text("No items ordered yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(orderVM.orders) { order in
                            VStack(alignment: .leading, spacing: 7) {
                                let sortedKeys = order.items.keys.sorted() // Precompute sorted keys
                                
                                ForEach(sortedKeys, id: \.self) { key in
                                    if let item = order.items[key] {
                                        UserTableOrderRow(item: item, orderId: order.id ?? "", reservationId: reservationId, orderVM: orderVM)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        
                        Divider()
                        
                        let restaurant = businessAuthVM.restaurant
                        // Display total price
                        HStack {
                            Text("Platform Fee:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(restaurant?.currencySymbol ?? "₹")3.00")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Show total price
                        HStack {
                            Text("Total Price:")
                                .font(.headline)
                            Spacer()
                            Text("\(restaurant?.currencySymbol ?? "₹")\(totalPrice, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(.mainbw)
                        }
                    }
                    
                    Spacer()
                    
                } else {
                    Text("Loading reservation details...")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Orders")
        }
        
        .onAppear {
            orderVM.fetchUserOrders(reservationId: reservationId)
        }
    }

}

struct UserTableOrderRow: View {
    let item: OrderItem
    let orderId: String
    let reservationId: String
    @ObservedObject var orderVM: OrdersViewModel
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel

    var body: some View {
        HStack {
            let restaurant = businessAuthVM.restaurant            
        
            Text("\(item.name) - \(item.quantity) x \(restaurant?.currencySymbol ?? "₹")\(item.price, specifier: "%.2f")")
                .font(.body)
            Spacer()
            
        }
    }
}
