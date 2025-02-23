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
    
    @ObservedObject var tableVM = TableViewModel()
    
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
            .onAppear {
                tableVM.isLoading = true
                tableVM.fetchOrderHistory()
            }
        }
    }
}

#Preview {
    OrdersView()
}

extension OrdersView {
    
    private var activeOrders : some View {
        ForEach(tableVM.reservations, id: \.id) { reservation in
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 5){
                    HStack{
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
                    }
                    
                    Spacer()
                    
                    if !reservation.isPaid {
                        Button(action: {
                            tableVM.deleteReservationAndSaveToHistory(reservationID: reservation.id)
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
                    
                }
                .padding(.top)
                // Text("Selected Tables: \(reservation.tables.map { String($0) }.joined(separator: ", "))")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    private var ordersHistory: some View {
        ForEach(tableVM.history, id: \.id) { historyItem in
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


