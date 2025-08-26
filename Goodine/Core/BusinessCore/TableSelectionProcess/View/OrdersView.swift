//
//  OrdersView.swift
//  Goodine
//
//  Created by Abhijit Saha on 16/02/25.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct OrdersView: View {
    
    @EnvironmentObject var tableVM : TableViewModel
    @State private var showFoodMenu = false
    @State private var showDeleteAlert = false
    @State private var showPayAlert = false
    @State private var selectedReservationID: String?
    @State private var seletedUserID: String?
    
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
                            
                            Text("Order History (\(tableVM.history.count))")
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
            .alert("Cancel Reservation", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    guard let reservationID = selectedReservationID else { return }
                    
                        if let userID = seletedUserID {
                            tableVM.deleteUserReservationWithID(reservationID: reservationID, userID: userID) { success, error in }
                        }
                        tableVM.deleteReservation(reservationID: reservationID) { success, error in }
                    
                }
            } message: {
                Text("Are you sure you want to delete this reservation?")
            }
            .alert("Confirm Payment", isPresented: $showPayAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Done", role: .none) {
                    guard let reservationID = selectedReservationID else { return }
                    
                    if let userID = seletedUserID {
                        tableVM.deleteAndSaveToHistory(reservationID: reservationID, userID: userID)
                    }
                    
                    tableVM.deleteReservationAndSaveToHistory(reservationID: reservationID)

                }

            } message: {
                Text("Do you want to complete the payment?")
            }
            .onAppear {
                tableVM.isLoading = true
                tableVM.fetchReservationsListener()
                tableVM.fetchOrderHistory()
            }
        }
    }
}

#Preview {
    OrdersView()
        .environmentObject(TableViewModel())
}

extension OrdersView {
    
    private var activeOrders : some View {
        ForEach(tableVM.reservations, id: \.id) { reservation in
            NavigationLink {
                ReservationDetailedView(reservationId: reservation.id)
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    VStack(alignment: .leading, spacing: 5){
                        HStack(alignment: .bottom){
                            Text("Booking Date: \(reservation.timestamp, formatter: dateFormatter)")
                                .font(.caption)
                            Spacer()
                            Text("\(reservation.timestamp, formatter: timeFormatter)")
                                .font(.caption)
                            
                            Button(action: {
                                selectedReservationID = reservation.id
                                showDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .offset(y: 2)
                            .disabled(tableVM.isLoading)
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
                                    selectedReservationID = reservation.id
                                    seletedUserID = reservation.userID ?? nil
                                    showPayAlert = true
                                }) {
                                    HStack {
                                        if tableVM.isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Text("Pay Bill")
                                        }
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.orange)
                                    .cornerRadius(10)
                                }
                                .padding(.top, 10)
                                .disabled(tableVM.isLoading) // Disable button while loading
                            }
                            
                            Button{
                                showFoodMenu.toggle()
                            }label: {
                                Text("Add Food")
                                    .foregroundStyle(.mainInvert)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.mainbw)
                            .cornerRadius(10)
                            
                            
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
                HistoryDetailedView(reservationId: historyItem.id)
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
