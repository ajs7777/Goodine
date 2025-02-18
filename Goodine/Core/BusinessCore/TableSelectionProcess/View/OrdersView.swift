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
                tableVM.fetchAllReservations()
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
                HStack {
                    Image("businessicon")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("Reservation ID: \(reservation.id)")
                        .font(.headline)
                }
                
                Text("Timestamp: \(reservation.timestamp, formatter: dateFormatter)")
                Text("Billing Time: \(reservation.billingTime, formatter: dateFormatter)")
                Text("Selected Tables: \(reservation.tables.map { String($0) }.joined(separator: ", "))")
                
                ForEach(reservation.tables, id: \.self) { table in
                    if let seats = reservation.seats[table] {
                        Text("Table \(table) Seats: \(seats.map { $0 ? "🔴" : "⚪" }.joined())")
                    }
                    if let count = reservation.peopleCount[table] {
                        Text("People at Table \(table): \(count)")
                    }
                }
                
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
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    .disabled(tableVM.isLoading) // Disable button while loading
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    private var ordersHistory: some View {
        ForEach(tableVM.history, id: \.id) { historyItem in
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.green)
                    
                    Text("Reservation ID: \(historyItem.id)")
                        .font(.headline)
                }
                
                Text("Timestamp: \(historyItem.timestamp, formatter: dateFormatter)")
                Text("Billing Time: \(historyItem.billingTime, formatter: dateFormatter)")
                Text("Selected Tables: \(historyItem.tables.map { String($0) }.joined(separator: ", "))")
                
                ForEach(historyItem.tables, id: \.self) { table in
                    if let seats = historyItem.seats[table] {
                        Text("Table \(table) Seats: \(seats.map { $0 ? "🔴" : "⚪" }.joined())")
                    }
                    if let count = historyItem.peopleCount[table] {
                        Text("People at Table \(table): \(count)")
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}


