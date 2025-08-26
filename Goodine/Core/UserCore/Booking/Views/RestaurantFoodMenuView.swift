
import SwiftUI
import Kingfisher

struct RestaurantFoodMenuView: View {
    
    let restaurantID: String
    
    @StateObject var orderVM : RestaurantOrdersViewModel
    @StateObject private var tableVM: RestaurantTableViewModel
    @StateObject var viewModel : MenuViewModel
    
    @StateObject var businessAuthVM : RestroDetailsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedItems: [String: Int] = [:]
    
    @State private var showOrderSummary = false
    
    @State private var selectedReservation: Reservation?

    
    init(restaurantID: String) {
        self.restaurantID = restaurantID
        _viewModel = StateObject(wrappedValue: MenuViewModel(restaurantID: restaurantID))
        _orderVM = StateObject(wrappedValue: RestaurantOrdersViewModel(restaurantID: restaurantID))
        _tableVM = StateObject(wrappedValue: RestaurantTableViewModel(restaurantID: restaurantID))
        _businessAuthVM = StateObject(wrappedValue: RestroDetailsViewModel(restaurantID: restaurantID))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.items) { item in
                            RestaurantFoodMenuItemView(item: item, selectedItems: $selectedItems, restaurant: businessAuthVM.restaurant)
                        }
                    }
                    
                }
                Button("Place Order") {
                    selectedReservation = tableVM.reservations.first
                    showOrderSummary = true
                }
                .goodineButtonStyle(.mainbw)
                .sheet(isPresented: $showOrderSummary) {
                    if let reservation = selectedReservation {
                        OrderSummaryView(
                            selectedItems: $selectedItems,
                            menuItems: viewModel.items,
                            restaurant: businessAuthVM.restaurant!,
                            currencySymbol: businessAuthVM.restaurant?.currencySymbol ?? "", reservation: reservation,
                            onConfirm: {
                                orderVM.saveOrderToFirestore(
                                    reservationId: reservation.id,
                                    selectedItems: selectedItems,
                                    menuItems: viewModel.items
                                )
                                dismiss()
                            }
                        )
                    } else {
                        // Optional fallback
                        Text("No reservation found.")
                    }
                }

            }
            .padding()
            .navigationTitle("Order Food")
        }
        
    }
}

struct RestaurantFoodMenuItemView: View {
    var item: MenuItem
    
    @Binding var selectedItems: [String: Int]
    @State private var quantity: Int = 0
    
    let restaurant : Restaurant?
    
    
    var body: some View {
        HStack(spacing: 10) {
            if let imageUrl = item.foodImage, let url = URL(string: imageUrl) {
                KFImage(url)
                    .resizable()
                    .placeholder { ProgressView() }
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .bottomLeading) {
                        VegNonVegIcon(size: 15, color: item.isVeg ? .green : .red)
                            .padding(8)
                    }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.mainbw.opacity(0.5))
                    .frame(width: 30, height: 30)
                    .padding(25)
                    .background(.mainbw.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .bottomLeading) {
                        VegNonVegIcon(size: 15, color: item.isVeg ? .green : .red)
                            .padding(8)
                    }
            }
            
            VStack(alignment: .leading) {
                Text(item.foodname)
                    .fontWeight(.bold)
                Text(item.foodDescription ?? "Food Description")
                    .font(.caption)
                    .foregroundStyle(.mainbw.opacity(0.5))
                
                Text("\(restaurant?.currencySymbol ?? "")\(item.foodPrice)")
                    .foregroundStyle(.mainbw.opacity(0.5))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    if quantity > 0 {
                        quantity -= 1
                        selectedItems[item.id] = quantity
                        if quantity == 0 {
                            selectedItems.removeValue(forKey: item.id)
                        }
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundStyle(.mainbw)
                        .font(.system(size: 15, weight: .heavy))
                        .frame(width: 25, height: 25)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .disabled(quantity == 0)
                .opacity(quantity == 0 ? 0.5 : 1.0)

                Text("\(quantity)")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 25, alignment: .center)

                Button(action: {
                    quantity += 1
                    selectedItems[item.id] = quantity
                }) {
                    Image(systemName: "plus")
                        .foregroundStyle(.mainbw)
                        .font(.system(size: 15, weight: .heavy))
                        .frame(width: 25, height: 25)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 1)
        }
        .onAppear {
            quantity = selectedItems[item.id] ?? 0
        }
    }
}
