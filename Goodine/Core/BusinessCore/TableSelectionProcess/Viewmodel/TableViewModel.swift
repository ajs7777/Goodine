//
//  TableViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 15/02/25.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

class TableViewModel: ObservableObject {
    
    @Published var rows: Int = 4
    @Published var columns: Int = 2
    @Published var tablePeopleCount: [Int: Int] = [:]
    @Published var selectedButtons: [[Bool]] = Array(repeating: Array(repeating: false, count: 4), count: 100)
    @Published var reservedSeats: [Int: [Bool]] = [:]
    @Published var isLoading = false
    @Published var currentTime = Date()
    @Published var selectedTable: Int? = nil
    @Published var reservations: [(id: String, tables: [Int], seats: [Int: [Bool]], peopleCount: [Int: Int], timestamp: Date, billingTime: Date, isPaid: Bool)] = [] {
        didSet {
            print("Reservations updated! Count: \(reservations.count)")
        }
    }
    
    @Published var history: [(id: String, tables: [Int], seats: [Int: [Bool]], peopleCount: [Int: Int], timestamp: Date, billingTime: Date)] = [] {
        didSet {
            print("History updated! Count: \(history.count)")
        }
    }
    
    
    func saveTableLayout() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No logged-in user found")
            return
        }
        
        let db = Firestore.firestore()
        let tableData: [String: Any] = [
            "rows": rows,
            "columns": columns,
            "userID": userID
        ]
        
        db.collection("business_users").document(userID).collection("tables").document("layout").setData(tableData) { error in
            if let error = error {
                print("Error saving table layout: \(error.localizedDescription)")
            } else {
                print("Table layout saved successfully for user \(userID)")
            }
        }
    }
    
    func fetchTableLayout() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No logged-in user found")
            return
        }
        
        isLoading = true
        let db = Firestore.firestore()
        let docRef = db.collection("business_users").document(userID).collection("tables").document("layout")
        
        docRef.getDocument { (document, error) in
            defer { self.isLoading = false }
            
            if let document = document, document.exists {
                if let data = document.data() {
                    self.rows = data["rows"] as? Int ?? 4
                    self.columns = data["columns"] as? Int ?? 2
                    print("Table layout fetched successfully for user \(userID)")
                }
            } else {
                print("Document does not exist or failed to fetch: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func saveAllSeatSelections() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No logged-in user found")
            return
        }
        
        for (tableNumber, seats) in selectedButtons.enumerated() {
            if let reservedSeatsForTable = reservedSeats[tableNumber] {
                for (index, isSelected) in seats.enumerated() {
                    if isSelected && reservedSeatsForTable.indices.contains(index) && reservedSeatsForTable[index] {
                        print("Cannot save reservation: Table \(tableNumber), Seat \(index) is already reserved.")
                        return
                    }
                }
            }
        }
        
        let db = Firestore.firestore()
        let reservationID = UUID().uuidString
        let reservationRef = db.collection("business_users").document(userID).collection("reservations").document(reservationID)
        
        var reservationData: [String: Any] = [
            "reservationID": reservationID, // Store the ID itself
            "timestamp": Timestamp(date: Date()) // Add timestamp
        ]
        
        // Save people count per table
        for (tableNumber, seatCount) in tablePeopleCount {
            reservationData["table_\(tableNumber)"] = seatCount
        }
        
        // Save seat selection states
        for tableIndex in 1...(rows * columns) {
            let seatStates = selectedButtons[tableIndex]
            reservationData["table_\(tableIndex)_seats"] = seatStates
        }
        
        print("Saving seat selections: \(reservationData)")
        
        reservationRef.setData(reservationData) { error in
            if let error = error {
                print("Error saving seat selections: \(error.localizedDescription)")
            } else {
                print("Seat selections saved successfully with ID: \(reservationID)")
                self.fetchAllSeatSelections {
                    DispatchQueue.main.async {
                        self.selectedButtons = Array(repeating: Array(repeating: false, count: 4), count: 100)
                        self.tablePeopleCount.removeAll()
                    }
                }
            }
        }
        
    }
    
    func fetchAllSeatSelections(completion: (() -> Void)? = nil) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let reservationCollection = db.collection("business_users").document(userID).collection("reservations")
        
        isLoading = true
        
        reservationCollection.getDocuments { (snapshot, error) in
            defer { self.isLoading = false }
            
            if let error = error {
                print("Error fetching reservations: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No reservations found.")
                DispatchQueue.main.async {
                               self.reservedSeats.removeAll()
                               self.objectWillChange.send() // Force SwiftUI to update UI
                           }
                return
            }
            
            var updatedReservedSeats = [Int: [Bool]]()
            var updatedPeopleCount = [Int: Int]()
            
            for document in documents {
                let data = document.data()
                
                for (key, value) in data {
                    if key.hasPrefix("table_"),
                       let tableNumber = Int(key.replacingOccurrences(of: "table_", with: "").components(separatedBy: "_").first ?? "") {
                        
                        if key.contains("_seats"), let seatData = value as? [Bool] {
                            if updatedReservedSeats[tableNumber] == nil {
                                updatedReservedSeats[tableNumber] = Array(repeating: false, count: 4)
                            }
                            for (index, isReserved) in seatData.enumerated() {
                                if isReserved {
                                    updatedReservedSeats[tableNumber]?[index] = true
                                }
                            }
                        } else if let peopleCount = value as? Int {
                            updatedPeopleCount[tableNumber, default: 0] += peopleCount
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.tablePeopleCount = updatedPeopleCount
                self.reservedSeats = updatedReservedSeats
                self.objectWillChange.send()
                print("Reserved Seats Updated for All Reservations: \(self.reservedSeats)")
                completion?()
            }
        }
    }
    
    func fetchAllReservations() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let reservationCollection = db.collection("business_users").document(userID).collection("reservations")
        
        isLoading = true
        reservations.removeAll()
        
        reservationCollection.getDocuments { (snapshot, error) in
            defer { self.isLoading = false }
            
            if let error = error {
                print("Error fetching reservations: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No reservations found.")
                return
            }
            
            for document in documents {
                let data = document.data()
                print("Fetched Reservation Data:", data)  // Debugging
                
                let reservationID = document.documentID
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                let billingTime = (data["billingTime"] as? Timestamp)?.dateValue() ?? Date()
                let isPaid = data["isPaid"] as? Bool ?? false
                
                var tables: [Int] = []
                var seats: [Int: [Bool]] = [:]
                var peopleCount: [Int: Int] = [:]
                
                for (key, value) in data {
                    if key.hasPrefix("table_") {
                        let components = key.components(separatedBy: "_")
                        if components.count == 2, let tableNumber = Int(components[1]) {
                            if let seatData = value as? [Bool] {
                                seats[tableNumber] = seatData
                            } else if let count = value as? Int {
                                tables.append(tableNumber)
                                peopleCount[tableNumber] = count
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.reservations.append((id: reservationID, tables: tables, seats: seats, peopleCount: peopleCount, timestamp: timestamp, billingTime: billingTime, isPaid: isPaid))
                }
            }
            
            print("Reservations Count:", self.reservations.count)
        }
    }
    
    func deleteReservationAndSaveToHistory(reservationID: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let reservationRef = db.collection("business_users").document(userID).collection("reservations").document(reservationID)
        let historyRef = db.collection("business_users").document(userID).collection("history").document(reservationID)
        
        isLoading = true // Start loading
        
        reservationRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if var data = document.data() {
                    let currentBillingTime = Date() // Get current timestamp
                    data["billingTime"] = Timestamp(date: currentBillingTime) // Update billing time
                    data["isPaid"] = true  // Mark as paid before moving to history
                    
                    
                    
                    // **1️⃣ Append to `history` list before saving to Firestore**
                    DispatchQueue.main.async {
                        self.history.append((
                            id: reservationID,
                            tables: data["tables"] as? [Int] ?? [],
                            seats: data["seats"] as? [Int: [Bool]] ?? [:],
                            peopleCount: data["peopleCount"] as? [Int: Int] ?? [:],
                            timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                            billingTime: currentBillingTime // Use updated billing time
                        ))
                    }
                    
                    // **1️⃣ Remove the reserved seats immediately before deleting**
                    DispatchQueue.main.async {
                        if let tables = data["tables"] as? [Int] {
                            for table in tables {
                                self.reservedSeats[table] = Array(repeating: false, count: 4) // Reset seats
                            }
                        }
                        self.fetchOrderHistory()
                        self.objectWillChange.send() // Force SwiftUI to update UI
                    }
                    
                    historyRef.setData(data) { error in
                        if let error = error {
                            print("Error saving to history: \(error.localizedDescription)")
                            DispatchQueue.main.async { self.isLoading = false }
                        } else {
                            reservationRef.delete { error in
                                DispatchQueue.main.async {
                                    if let error = error {
                                        print("Error deleting reservation: \(error.localizedDescription)")
                                    } else {
                                        print("Reservation moved to history and deleted successfully")
                                        
                                        self.reservations.removeAll { $0.id == reservationID }
                                        
                                        self.fetchAllSeatSelections {
                                            self.fetchOrderHistory()
                                            DispatchQueue.main.async {
                                                self.objectWillChange.send()
                                                self.isLoading = false // Stop loading
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async { self.isLoading = false }
                }
            } else {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }
    
    func fetchOrderHistory() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let historyCollection = db.collection("business_users").document(userID).collection("history")
        
        isLoading = true
        history.removeAll()
        
        historyCollection.getDocuments { (snapshot, error) in
            defer { self.isLoading = false }
            
            if let error = error {
                print("Error fetching order history: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No order history found.")
                return
            }
            
            var fetchedHistory: [(id: String, tables: [Int], seats: [Int: [Bool]], peopleCount: [Int: Int], timestamp: Date, billingTime: Date)] = []
            
            for document in documents {
                let data = document.data()
                let reservationID = document.documentID
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                let billingTime = (data["billingTime"] as? Timestamp)?.dateValue() ?? Date()
                
                var tables: [Int] = []
                var seats: [Int: [Bool]] = [:]
                var peopleCount: [Int: Int] = [:]
                
                for (key, value) in data {
                    if key.hasPrefix("table_") {
                        let components = key.components(separatedBy: "_")
                        if components.count == 2, let tableNumber = Int(components[1]) {
                            if let seatData = value as? [Bool] {
                                seats[tableNumber] = seatData
                            } else if let count = value as? Int {
                                tables.append(tableNumber)
                                peopleCount[tableNumber] = count
                            }
                        }
                    }
                }
                
                fetchedHistory.append((id: reservationID, tables: tables, seats: seats, peopleCount: peopleCount, timestamp: timestamp, billingTime: billingTime))
            }
            
            fetchedHistory.sort { $0.billingTime > $1.billingTime }
            
            DispatchQueue.main.async {
                self.history = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.history = fetchedHistory
                    print("History updated after delay! Count: \(self.history.count)")
                }
            }
            
        }
    }
    
}
