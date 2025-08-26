
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
        fetchUserReservationsListener()
        fetchHistoryListener()
        fetchUserHistoryListener()
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
    
    func fetchSeatSelections(completion: (() -> Void)? = nil) {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged-in user found."
            completion?()
            return
        }
        let db = Firestore.firestore()
        let reservationCollection = db.collection("users")
            .document(userID)
            .collection("currentOrders")
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
    func fetchReservationsListener() {
        guard let buserID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let reservationCollection = db.collection("business_users")
            .document(buserID)
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
                let reservation = Reservation(id: reservationID,
                                              tables: tables,
                                              seats: seats,
                                              peopleCount: peopleCount,
                                              timestamp: timestamp,
                                              billingTime: billingTime,
                                              isPaid: isPaid,
                                              userID: userID,
                                              restaurantID: restaurantID)
                newReservations.append(reservation)
            }
            
            let sortedReservations = newReservations.sorted { $0.timestamp > $1.timestamp }
            
            DispatchQueue.main.async {
                self.reservations = sortedReservations
            }
            print("Reservations Updated: \(newReservations.count)")
        }
    }
    
    private func fetchUserReservationsListener() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let reservationCollection = db.collection("users")
            .document(userID)
            .collection("currentOrders")
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
                let reservation = Reservation(id: reservationID,
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
    
    func deleteAndSaveToHistory(reservationID: String, userID: String) {
        
        let db = Firestore.firestore()
        let reservationRef = db.collection("users")
            .document(userID)
            .collection("currentOrders")
            .document(reservationID)
        let historyRef = db.collection("users")
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
                    self.fetchSeatSelections {
                        self.fetchUserOrderHistory()
                    }
                }
            }
        }
    }
    
    func deleteReservation(reservationID: String, completion: @escaping (Bool, String?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false, "No logged-in user found.")
            return
        }
        
        let db = Firestore.firestore()
        let reservationRef = db.collection("business_users")
            .document(userID)
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
    
    func deleteRestaurantReservation(reservationID: String, restaurantID: String, completion: @escaping (Bool, String?) -> Void) {
                
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
    
    func deleteUserReservation(reservationID: String, completion: @escaping (Bool, String?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false, "No logged-in user found.")
            return
        }
        
        let db = Firestore.firestore()
        let reservationRef = db.collection("users")
            .document(userID)
            .collection("currentOrders")
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
                self?.deleteUserReservationDocument(reservationRef: reservationRef, reservationID: reservationID, completion: completion)
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
                    self?.deleteUserReservationDocument(reservationRef: reservationRef, reservationID: reservationID, completion: completion)
                }
            }
        }
    }
    
    func deleteUserReservationWithID(reservationID: String, userID: String, completion: @escaping (Bool, String?) -> Void) {
        
        let db = Firestore.firestore()
        let reservationRef = db.collection("users")
            .document(userID)
            .collection("currentOrders")
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
                self?.deleteUserReservationDocument(reservationRef: reservationRef, reservationID: reservationID, completion: completion)
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
                    self?.deleteUserReservationDocument(reservationRef: reservationRef, reservationID: reservationID, completion: completion)
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
    
    private func deleteUserReservationDocument(reservationRef: DocumentReference, reservationID: String, completion: @escaping (Bool, String?) -> Void) {
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
                    self?.fetchSeatSelections {
                        completion(true, nil)
                    }
                    
                    print("Reservation and all associated orders deleted successfully")
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
    
    func fetchUserOrderHistory() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged-in user found."
            return
        }
        let db = Firestore.firestore()
        let historyCollection = db.collection("users")
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
    
    private func fetchUserHistoryListener() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let historyCollection = db.collection("users")
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
