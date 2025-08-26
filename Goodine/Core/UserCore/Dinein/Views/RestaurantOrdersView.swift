
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct RestaurantOrdersView: View {
    
    @EnvironmentObject var tableVM : TableViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showFoodMenu = false
    @State private var showCancelAlert = false
    @State private var selectedReservationID: String?
    @State private var seletedRestaurantID: String?
    
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
    
    private let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack {
                if tableVM.isLoading {
                    ProgressView("Loading reservations...")
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            
                            Text("Active Reservations (\(tableVM.reservations.count))")
                                .font(.title2)
                                .bold()
                                .padding(.leading)
                            
                            if tableVM.reservations.isEmpty {
                                Text("No active reservations")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                activeOrders
                            }
                            
                            Text("Order History")
                                .font(.title2)
                                .bold()
                                .padding(.leading)
                            
                            if tableVM.history.isEmpty {
                                Text("No order history available")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ordersHistory
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Orders & History")
            .onAppear {
                tableVM.isLoading = true
                tableVM.fetchUserOrderHistory()
            }
            .alert("Cancel Order", isPresented: $showCancelAlert) {
                Button("No", role: .cancel) { }
                Button("Yes", role: .destructive) {
                    if let reservationID = selectedReservationID {
                        if let restaurantID = seletedRestaurantID {
                            tableVM.deleteRestaurantReservation(reservationID: reservationID, restaurantID: restaurantID) { success, error in }
                            print(restaurantID)
                        }
                        tableVM.deleteUserReservation(reservationID: reservationID) { success, error in }
                    }
                }
            } message: {
                Text("Are you sure you want to cancel this order?")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .bold()
                        .foregroundStyle(.mainbw)
                }
            }
        }
    }
}

#Preview {
    RestaurantOrdersView()
}

extension RestaurantOrdersView {
    
    private var activeOrders : some View {
        ForEach(tableVM.reservations, id: \.id) { reservation in
            NavigationLink {
                UserReservationDetailedView(reservationId: reservation.id)
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    VStack(alignment: .leading, spacing: 5){
                        HStack(alignment: .bottom){
                            Text("Booking Date: \(reservation.timestamp, formatter: dateFormatter)")
                                .font(.caption)
                            Spacer()
                            Text("\(reservation.timestamp, formatter: timeFormatter)")
                                .font(.caption)
                         }
                        
                        let shortID = String(reservation.id.suffix(12))
                        Text("ID: \(shortID)")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                    
                    HStack {
                        Image("businessicon")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .padding(.top)
                        
                        VStack{
                            ForEach(
                                reservation.tables.filter { tableNumber in
                                    let seatArray = reservation.seats[tableNumber] ?? []
                                    return seatArray.contains(true)
                                },
                                id: \.self
                            ) { tableNumber in
                                let seatArray = reservation.seats[tableNumber] ?? []
                                let selectedSeatCount = seatArray.filter { $0 }.count
                                HStack{
                                    if selectedSeatCount > 0 {
                                        Text("Table \(tableNumber) : \(selectedSeatCount)")
                                    }
                                    Image(systemName: "person.fill")
                                }
                                
                            }
                        } .font(.footnote)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing){
                            if !reservation.isPaid {
                                Button(action: {
                                    seletedRestaurantID = reservation.restaurantID
                                    selectedReservationID = reservation.id
                                    showCancelAlert = true
                                }) {
                                    HStack {
                                        if tableVM.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Text("Cancel")
                                        }
                                    }
                                    .fontWeight(.semibold)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.red)
                                    .cornerRadius(10)
                                }
                                .padding(.top, 10)
                                .disabled(tableVM.isLoading)
                            }
                            
                        }
                        
                        
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
        }
        .sheet(isPresented: $showFoodMenu, content: { FoodMenuView() })
    }
    
    private var ordersHistory: some View {
        ForEach(tableVM.history, id: \.id) { historyItem in
            NavigationLink {
                UserHistoryDetailedView(reservationId: historyItem.id)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    
                    VStack(alignment: .leading, spacing: 5){
                        HStack{
                            Text("Booking Date: \(historyItem.timestamp, formatter: dateFormatter)")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            
                            Spacer()
                            
                            Text("\(historyItem.timestamp, formatter: timeFormatter)")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        let shortID = String(historyItem.id.suffix(12))
                        Text("ID: \(shortID)")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 50)
                            .foregroundColor(.gray)
                        
                        VStack {
                            ForEach(
                                historyItem.tables.filter { tableNumber in
                                    let seatArray = historyItem.seats[tableNumber] ?? []
                                    return seatArray.contains(true)
                                },
                                id: \.self
                            ) { tableNumber in
                                HStack{
                                    let seatArray = historyItem.seats[tableNumber] ?? []
                                    let selectedSeatCount = seatArray.filter { $0 }.count
                                    Text("Table \(tableNumber) : \(selectedSeatCount)")
                                    Image(systemName: "person.fill")
                                }
                                
                            }
                        }
                        Spacer()
                        
                        HStack{
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Paid")
                        }
                        .font(.headline)
                        
                    }
                    
                    HStack(){
                        Spacer()
                        Text("Billing Time: \(historyItem.billingTime, formatter: dateTimeFormatter)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    
                    
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
        }
    }
}
