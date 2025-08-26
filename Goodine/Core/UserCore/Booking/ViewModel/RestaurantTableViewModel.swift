
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

@MainActor
class RestaurantTableViewModel: ObservableObject {
    
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
    
    private var restaurantID: String

    // MARK: - Initializer
    
    init(restaurantID: String) {
        self.restaurantID = restaurantID
        updateSelectedButtons()
        // Setup real‑time listeners
        fetchReservationsListener()
        fetchTableLayoutListener()
    }
    
    deinit {
        reservationListener?.remove()
        historyListener?.remove()
        layoutListener?.remove()
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
    
    /// Set up a real‑time listener for table layout.
    private func fetchTableLayoutListener() {
        let db = Firestore.firestore()
        let layoutRef = db.collection("business_users")
            .document(restaurantID)
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
        }
    }
    
    // MARK: - Reservation Methods
    
    /// Save all seat selections as a new reservation.
    func saveAllSeatSelections() {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            print("User not authenticated")
            return
        }

        // Merge conflict checking and data preparation in one loop.
        var reservationData: [String: Any] = [
            "reservationID": UUID().uuidString,
            "timestamp": Timestamp(date: Date()),
            "isPaid": false,
            "userID": userID,
            "restaurantID": restaurantID
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

        let businessRef = db.collection("business_users")
            .document(restaurantID)
            .collection("reservations")
            .document(reservationID)

        let userRef = db.collection("users")
            .document(userID)
            .collection("currentOrders")
            .document(reservationID)

        let batch = db.batch()
        batch.setData(reservationData, forDocument: businessRef)
        batch.setData(reservationData, forDocument: userRef)

        batch.commit { error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            if let error = error {
                self.logError(error)
            } else {
                print("Seat selections saved to both business and user path with ID: \(reservationID)")
                self.resetSeatSelections()
                self.fetchAllSeatSelections()
            }
        }
    }

    
    /// Fetch all seat selections from reservations.
    func fetchAllSeatSelections(completion: (() -> Void)? = nil) {
        
        let db = Firestore.firestore()
        let reservationCollection = db.collection("business_users")
            .document(restaurantID)
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
        let db = Firestore.firestore()
        let reservationCollection = db.collection("business_users")
            .document(restaurantID)
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
                let userID = data["userID"] as? String
                let restaurantID = data["restaurantID"] as? String

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

                let reservation = Reservation(
                    id: reservationID,
                    tables: tables,
                    seats: seats,
                    peopleCount: peopleCount,
                    timestamp: timestamp,
                    billingTime: billingTime,
                    isPaid: isPaid,
                    userID: userID,
                    restaurantID: restaurantID
                )

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
    
    
    func deleteReservation(reservationID: String, completion: @escaping (Bool, String?) -> Void) {
              
        let db = Firestore.firestore()
        let reservationRef = db.collection("business_users")
            .document(restaurantID)
            .collection("reservations")
            .document(reservationID)
        
        // Reference to the orders subcollection
        let ordersCollectionRef = reservationRef.collection("orders")
        
        isLoading = true
        
        // Step 1: Delete all documents in the orders subcollection
        ordersCollectionRef.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                self?.logError(error)
                completion(false, "Failed to retrieve orders: \(error.localizedDescription)")
                return
            }
            
            // If no orders or error retrieving them, proceed with reservation deletion
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                // No orders to delete, proceed to delete the reservation document
                self?.deleteReservationDocument(reservationRef: reservationRef, reservationID: reservationID, completion: completion)
                return
            }
            
            // Create a batch to delete all order documents
            let batch = db.batch()
            
            // Add each order document to the batch for deletion
            for document in documents {
                batch.deleteDocument(document.reference)
            }
            
            // Commit the batch delete of all orders
            batch.commit { [weak self] error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.isLoading = false
                    }
                    self?.logError(error)
                    completion(false, "Failed to delete orders: \(error.localizedDescription)")
                } else {
                    // Orders deleted successfully, now delete the reservation document
                    self?.deleteReservationDocument(reservationRef: reservationRef, reservationID: reservationID, completion: completion)
                }
            }
        }
    }

    // Helper function to delete the reservation document itself
    private func deleteReservationDocument(reservationRef: DocumentReference, reservationID: String, completion: @escaping (Bool, String?) -> Void) {
        // First get the document to identify any fields we need for cleanup
        reservationRef.getDocument { [weak self] (document, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                self?.logError(error)
                completion(false, "Failed to retrieve reservation: \(error.localizedDescription)")
                return
            }
            
            let data = document?.data() ?? [:]
            
            // Delete the reservation document
            reservationRef.delete { [weak self] error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                }
                
                if let error = error {
                    self?.logError(error)
                    completion(false, "Failed to delete reservation: \(error.localizedDescription)")
                } else {
                    // Clean up local data
                    DispatchQueue.main.async {
                        // Remove from local array
                        self?.reservations.removeAll { $0.id == reservationID }
                        
                        // Reset any reserved seats associated with this reservation
                        if let tables = data["tables"] as? [Int] {
                            for table in tables {
                                self?.reservedSeats[table] = Array(repeating: false, count: 4)
                            }
                        }
                    }
                    
                    // Refresh data
                    self?.fetchAllSeatSelections {
                        completion(true, nil)
                    }
                    
                    print("Reservation and all associated orders deleted successfully")
                }
            }
        }
    }
}
