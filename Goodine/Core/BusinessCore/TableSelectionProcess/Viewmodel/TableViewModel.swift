//
//  TableViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 15/02/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

@MainActor
class TableViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var rows: Int = 4 {
        didSet { updateSelectedButtons() }
    }
    @Published var columns: Int = 2 {
        didSet { updateSelectedButtons() }
    }
    
    /// Number of people per table.
    @Published var tablePeopleCount: [Int: Int] = [:]
    
    /// Dictionary mapping table number to an array of Booleans representing seat selections.
    @Published var selectedButtons: [Int: [Bool]] = [:]
    
    /// Dictionary mapping table number to an array of Booleans representing reserved seats.
    @Published var reservedSeats: [Int: [Bool]] = [:]
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedTable: Int? = nil
    
    @Published var reservations: [Reservation] = [] {
        didSet {
            print("Reservations updated! Count: \(reservations.count)")
        }
    }
    
    @Published var history: [HistoryRecord] = [] {
        didSet {
            print("History updated! Count: \(history.count)")
        }
    }
    
    // MARK: - Private Properties
    
    private var reservationListener: ListenerRegistration?
    private var historyListener: ListenerRegistration?
    private var layoutListener: ListenerRegistration?
    
    // MARK: - Initializer
    
    init() {
        updateSelectedButtons()
        // Setup real‑time listeners
        fetchReservationsListener()
        fetchHistoryListener()
        fetchTableLayoutListener()
    }
    
    deinit {
        reservationListener?.remove()
        historyListener?.remove()
        layoutListener?.remove()
    }
    
    // MARK: - Data Structures
    
    /// Reservation model.
    struct Reservation: Identifiable, Codable {
        var id: String
        var tables: [Int]
        var seats: [Int: [Bool]]
        var peopleCount: [Int: Int]
        var timestamp: Date
        var billingTime: Date?
        var isPaid: Bool
    }
    
    /// History record model.
    struct HistoryRecord: Identifiable, Codable {
        var id: String
        var tables: [Int]
        var seats: [Int: [Bool]]
        var peopleCount: [Int: Int]
        var timestamp: Date
        var billingTime: Date
    }
    
    // MARK: - Helper Methods
    
    /// Log and update error message.
    func logError(_ error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
        print("Error: \(error.localizedDescription)")
    }
    
    /// Update `selectedButtons` based on current table layout.
    private func updateSelectedButtons() {
        let tableCount = rows * columns
        // Ensure every table number from 1 to tableCount is initialized.
        for table in 1...tableCount {
            if selectedButtons[table] == nil {
                // Initialize with 4 seats per table.
                selectedButtons[table] = Array(repeating: false, count: 4)
            }
        }
    }
    
    /// Reset all seat selections and people counts.
    private func resetSeatSelections() {
        let tableCount = rows * columns
        for table in 1...tableCount {
            selectedButtons[table] = Array(repeating: false, count: 4)
        }
        tablePeopleCount.removeAll()
    }
    
    // MARK: - Table Layout Methods
    
    /// Save the current table layout to Firestore.
    func saveTableLayout() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged-in user found."
            return
        }
        isLoading = true
        let db = Firestore.firestore()
        let tableData: [String: Any] = [
            "rows": rows,
            "columns": columns,
            "userID": userID
        ]
        db.collection("business_users")
            .document(userID)
            .collection("tables")
            .document("layout")
            .setData(tableData) { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                if let error = error {
                    self.logError(error)
                } else {
                    print("Table layout saved successfully for user \(userID)")
                }
            }
    }
    
    /// Set up a real‑time listener for table layout.
    private func fetchTableLayoutListener() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let layoutRef = db.collection("business_users")
            .document(userID)
            .collection("tables")
            .document("layout")
        layoutListener = layoutRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                self.logError(error)
                return
            }
            guard let document = documentSnapshot, document.exists,
                  let data = document.data() else {
                print("No layout document found.")
                return
            }
            // Update on the main thread
            DispatchQueue.main.async {
                self.rows = data["rows"] as? Int ?? 4
                self.columns = data["columns"] as? Int ?? 2
                self.updateSelectedButtons()
            }
            print("Table layout fetched successfully for user \(userID)")
        }
    }
    
    // MARK: - Reservation Methods
    
    /// Save all seat selections as a new reservation.
    func saveAllSeatSelections() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged-in user found."
            return
        }
        
        // Merge conflict checking and data preparation in one loop.
        var reservationData: [String: Any] = [
            "reservationID": UUID().uuidString,
            "timestamp": Timestamp(date: Date()),
            "isPaid": false
        ]
        
        for (tableNumber, seatStates) in selectedButtons {
            // Check if there is a conflict with reserved seats.
            if let reserved = reservedSeats[tableNumber] {
                for (index, isSelected) in seatStates.enumerated() {
                    if isSelected, index < reserved.count, reserved[index] {
                        errorMessage = "Cannot reserve: Table \(tableNumber), Seat \(index) is already reserved."
                        print(errorMessage!)
                        return
                    }
                }
            }
            // Add seat selection and people count (if any) to the reservation data.
            reservationData["table_\(tableNumber)_seats"] = seatStates
            if let count = tablePeopleCount[tableNumber] {
                reservationData["table_\(tableNumber)"] = count
            }
        }
        
        print("Saving seat selections: \(reservationData)")
        isLoading = true
        let db = Firestore.firestore()
        let reservationID = reservationData["reservationID"] as! String
        let reservationRef = db.collection("business_users")
            .document(userID)
            .collection("reservations")
            .document(reservationID)
        reservationRef.setData(reservationData) { error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            if let error = error {
                self.logError(error)
            } else {
                print("Seat selections saved successfully with ID: \(reservationID)")
                self.resetSeatSelections()
                self.fetchAllSeatSelections()
            }
        }
    }
    
    /// Fetch all seat selections from reservations.
    func fetchAllSeatSelections(completion: (() -> Void)? = nil) {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged-in user found."
            completion?()
            return
        }
        let db = Firestore.firestore()
        let reservationCollection = db.collection("business_users")
            .document(userID)
            .collection("reservations")
        isLoading = true
        
        reservationCollection.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            if let error = error {
                self.logError(error)
                completion?()
                return
            }
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No reservations found.")
                DispatchQueue.main.async {
                    self.reservedSeats.removeAll()
                }
                completion?()
                return
            }
            
            var updatedReservedSeats = [Int: [Bool]]()
            var updatedPeopleCount = [Int: Int]()
            
            // Loop through each reservation document.
            for document in documents {
                let data = document.data()
                for (key, value) in data {
                    if key.hasPrefix("table_") {
                        let components = key.components(separatedBy: "_")
                        if components.count >= 2, let tableNumber = Int(components[1]) {
                            if key.contains("seats"), let seatData = value as? [Bool] {
                                let defaultSeats = updatedReservedSeats[tableNumber] ?? Array(repeating: false, count: 4)
                                // Combine current and new seat selections.
                                let combinedSeats = zip(defaultSeats, seatData).map { $0 || $1 }
                                updatedReservedSeats[tableNumber] = combinedSeats
                            } else if let peopleCount = value as? Int {
                                updatedPeopleCount[tableNumber, default: 0] += peopleCount
                            }
                        }
                    }
                }
            }
            // Update on the main thread.
            DispatchQueue.main.async {
                self.tablePeopleCount = updatedPeopleCount
                self.reservedSeats = updatedReservedSeats
            }
            print("Reserved Seats Updated: \(updatedReservedSeats)")
            completion?()
        }
    }
    
    /// Set up a real‑time listener for reservations.
    private func fetchReservationsListener() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let reservationCollection = db.collection("business_users")
            .document(userID)
            .collection("reservations")
        reservationListener = reservationCollection.addSnapshotListener { snapshot, error in
            if let error = error {
                self.logError(error)
                return
            }
            guard let documents = snapshot?.documents else { return }
            var newReservations: [Reservation] = []
            for document in documents {
                let data = document.data()
                let reservationID = document.documentID
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                let billingTime = (data["billingTime"] as? Timestamp)?.dateValue()
                let isPaid = data["isPaid"] as? Bool ?? false
                var tables: [Int] = []
                var seats: [Int: [Bool]] = [:]
                var peopleCount: [Int: Int] = [:]
                
                for (key, value) in data {
                    if key.hasPrefix("table_") {
                        let components = key.components(separatedBy: "_")
                        if components.count >= 2, let tableNumber = Int(components[1]) {
                            if key.contains("seats"), let seatData = value as? [Bool] {
                                seats[tableNumber] = seatData
                            } else if let count = value as? Int {
                                if !tables.contains(tableNumber) {
                                    tables.append(tableNumber)
                                }
                                peopleCount[tableNumber] = count
                            }
                        }
                    }
                }
                let reservation = Reservation(id: reservationID,
                                              tables: tables,
                                              seats: seats,
                                              peopleCount: peopleCount,
                                              timestamp: timestamp,
                                              billingTime: billingTime,
                                              isPaid: isPaid)
                newReservations.append(reservation)
            }
            
            let sortedReservations = newReservations.sorted { $0.timestamp > $1.timestamp }
            
            DispatchQueue.main.async {
                self.reservations = sortedReservations
            }
            print("Reservations Updated: \(newReservations.count)")
        }
    }
    
    // MARK: - History Methods
    
    /// Delete a reservation and save it to history.
    func deleteReservationAndSaveToHistory(reservationID: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged-in user found."
            return
        }
        let db = Firestore.firestore()
        let reservationRef = db.collection("business_users")
            .document(userID)
            .collection("reservations")
            .document(reservationID)
        let historyRef = db.collection("business_users")
            .document(userID)
            .collection("history")
            .document(reservationID)
        
        isLoading = true
        reservationRef.getDocument { documentSnapshot, error in
            if let error = error {
                self.logError(error)
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            guard let document = documentSnapshot, document.exists,
                  var data = document.data() else {
                DispatchQueue.main.async { self.isLoading = false }
                return
            }
            let currentBillingTime = Date()
            data["billingTime"] = Timestamp(date: currentBillingTime)
            data["isPaid"] = true
            
            // Prepare local history record.
            var tables: [Int] = []
            var seats: [Int: [Bool]] = [:]
            var peopleCount: [Int: Int] = [:]
            for (key, value) in data {
                if key.hasPrefix("table_") {
                    let components = key.components(separatedBy: "_")
                    if components.count >= 2, let tableNumber = Int(components[1]) {
                        if key.contains("seats"), let seatData = value as? [Bool] {
                            seats[tableNumber] = seatData
                        } else if let count = value as? Int {
                            if !tables.contains(tableNumber) {
                                tables.append(tableNumber)
                            }
                            peopleCount[tableNumber] = count
                        }
                    }
                }
            }
            let historyRecord = HistoryRecord(id: reservationID,
                                              tables: tables,
                                              seats: seats,
                                              peopleCount: peopleCount,
                                              timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                                              billingTime: currentBillingTime)
            DispatchQueue.main.async {
                self.history.append(historyRecord)
            }
            
            // Update reserved seats locally.
            if let tables = data["tables"] as? [Int] {
                for table in tables {
                    self.reservedSeats[table] = Array(repeating: false, count: 4)
                }
            }
            
            // Use a batch write for atomicity.
            let batch = db.batch()
            batch.setData(data, forDocument: historyRef)
            batch.deleteDocument(reservationRef)
            
            batch.commit { error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                if let error = error {
                    self.logError(error)
                } else {
                    print("Reservation moved to history and deleted successfully")
                    DispatchQueue.main.async {
                        self.reservations.removeAll { $0.id == reservationID }
                    }
                    self.fetchAllSeatSelections {
                        self.fetchOrderHistory()
                    }
                }
            }
        }
    }
    
    /// Fetch order history once.
    func fetchOrderHistory() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged-in user found."
            return
        }
        let db = Firestore.firestore()
        let historyCollection = db.collection("business_users")
            .document(userID)
            .collection("history")
        isLoading = true
        
        historyCollection.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            if let error = error {
                self.logError(error)
                return
            }
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("No order history found.")
                DispatchQueue.main.async {
                    self.history.removeAll()
                }
                return
            }
            var fetchedHistory: [HistoryRecord] = []
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
                        if components.count >= 2, let tableNumber = Int(components[1]) {
                            if key.contains("seats"), let seatData = value as? [Bool] {
                                seats[tableNumber] = seatData
                            } else if let count = value as? Int {
                                if !tables.contains(tableNumber) {
                                    tables.append(tableNumber)
                                }
                                peopleCount[tableNumber] = count
                            }
                        }
                    }
                }
                let record = HistoryRecord(id: reservationID,
                                           tables: tables,
                                           seats: seats,
                                           peopleCount: peopleCount,
                                           timestamp: timestamp,
                                           billingTime: billingTime)
                fetchedHistory.append(record)
            }
            
            let sortedHistory = fetchedHistory.sorted { $0.billingTime > $1.billingTime }
            
            DispatchQueue.main.async {
                self.history = sortedHistory
            }
            print("Fetched Order History: \(fetchedHistory.count)")
        }
    }
    
    /// Set up a real‑time listener for history.
    private func fetchHistoryListener() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let historyCollection = db.collection("business_users")
            .document(userID)
            .collection("history")
        historyListener = historyCollection.addSnapshotListener { snapshot, error in
            if let error = error {
                self.logError(error)
                return
            }
            guard let documents = snapshot?.documents else { return }
            var fetchedHistory: [HistoryRecord] = []
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
                        if components.count >= 2, let tableNumber = Int(components[1]) {
                            if key.contains("seats"), let seatData = value as? [Bool] {
                                seats[tableNumber] = seatData
                            } else if let count = value as? Int {
                                if !tables.contains(tableNumber) {
                                    tables.append(tableNumber)
                                }
                                peopleCount[tableNumber] = count
                            }
                        }
                    }
                }
                let record = HistoryRecord(id: reservationID,
                                           tables: tables,
                                           seats: seats,
                                           peopleCount: peopleCount,
                                           timestamp: timestamp,
                                           billingTime: billingTime)
                fetchedHistory.append(record)
            }
            
            let sortedHistory = fetchedHistory.sorted { $0.billingTime > $1.billingTime }
            
            DispatchQueue.main.async {
                self.history = sortedHistory
            }
            print("Real-time Order History Updated: \(fetchedHistory.count)")
        }
    }
}
