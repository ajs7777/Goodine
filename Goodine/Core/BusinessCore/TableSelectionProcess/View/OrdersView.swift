import SwiftUI
import Firebase

struct OrdersView: View {
    @State private var orders: [Reservation] = []
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Orders...")
                } else if orders.isEmpty {
                    Text("No Orders Found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(orders) { order in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🆔 Reservation ID: \(order.id)")
                                    .font(.headline)
                                Text("🍽 Table: \(order.tableNumber)")
                                Text("👥 People: \(order.peopleCount)")
                                Text("💺 Seats: \(order.selectedSeats.joined(separator: ", "))")

                                Button(action: {
                                    payBill(for: order)
                                }) {
                                    Text("Pay Bill 💳")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Orders")
            .onAppear(perform: fetchOrders)
        }
    }

    // Fetch Orders from Firestore
    func fetchOrders() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let reservationsRef = db.collection("business_users").document(userID).collection("reservations")

        isLoading = true

        reservationsRef.getDocuments { (snapshot, error) in
            DispatchQueue.main.async {
                isLoading = false
            }
            if let error = error {
                print("❌ Error fetching orders: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("ℹ️ No orders found")
                return
            }

            let fetchedOrders = documents.map { doc -> Reservation in
                let data = doc.data()
                let id = doc.documentID
                let tableNumber = data["tableNumber"] as? Int ?? 0
                let peopleCount = data["peopleCount"] as? Int ?? 0
                let selectedSeats = data["selectedSeats"] as? [String] ?? []

                return Reservation(id: id, tableNumber: tableNumber, peopleCount: peopleCount, selectedSeats: selectedSeats)
            }

            DispatchQueue.main.async {
                self.orders = fetchedOrders
            }
        }
    }

    // Unlock Seats and Delete Reservation
    func payBill(for order: Reservation) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let reservationRef = db.collection("business_users").document(userID).collection("reservations").document(order.id)

        reservationRef.delete { error in
            if let error = error {
                print("❌ Error deleting reservation: \(error.localizedDescription)")
            } else {
                print("✅ Reservation \(order.id) removed")
                self.orders.removeAll { $0.id == order.id } // Remove from UI
            }
        }
    }
}

// Reservation Model
struct Reservation: Identifiable {
    let id: String
    let tableNumber: Int
    let peopleCount: Int
    let selectedSeats: [String] // ["Seat 1", "Seat 2"]
}
