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
                Button(action: {
                    tableVM.fetchAllReservations()
                }) {
                    Text("Refresh Reservations")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        
                        // Active Reservations
                        Text("Active Reservations (\(tableVM.reservations.count))")
                            .font(.title2)
                            .bold()
                            .padding(.leading)
                        
                        if tableVM.reservations.isEmpty {
                            Text("No active reservations")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(tableVM.reservations, id: \.id) { reservation in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Reservation ID: \(reservation.id)")
                                        .font(.headline)
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
                                            Text("Pay Bill")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.red)
                                                .cornerRadius(10)
                                        }
                                        .padding(.top, 10)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        
                        // Order History
                        Text("Order History (\(tableVM.history.count))")
                            .font(.title2)
                            .bold()
                            .padding(.leading)
                        
                        if tableVM.history.isEmpty {
                            Text("No order history available")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(tableVM.history, id: \.id) { historyItem in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Reservation ID: \(historyItem.id)")
                                        .font(.headline)
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
                    .padding()
                }
                .navigationTitle("Orders & History")
                .onAppear {
                    tableVM.fetchAllReservations()
                    tableVM.fetchOrderHistory()
                }
            }
        }
    }
}

#Preview {
    OrdersView()
}



