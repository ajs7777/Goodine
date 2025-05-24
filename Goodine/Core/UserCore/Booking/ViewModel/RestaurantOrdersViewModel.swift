


import Foundation
import FirebaseFirestore
import FirebaseAuth

class RestaurantOrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []

    private let db = Firestore.firestore()
    private var restaurantID: String
    
    init(restaurantID: String){
        self.restaurantID = restaurantID
    }

    func saveOrderToFirestore(
        reservationId: String,
        selectedItems: [String: Int],
        menuItems: [MenuItem]
    ) {
        let ordersRef = db.collection("business_users")
                          .document(restaurantID)
                          .collection("reservations")
                          .document(reservationId)
                          .collection("orders")
                          .document()

        var orderData: [String: OrderItem] = [:]

        for (itemId, quantity) in selectedItems {
            if let menuItem = menuItems.first(where: { $0.id == itemId }) {
                orderData[itemId] = OrderItem(name: menuItem.foodname, price: Double(menuItem.foodPrice), quantity: quantity)
            }
        }

        let orderDetails = Order(
            id: ordersRef.documentID,
            userId: restaurantID,
            items: orderData,
            timestamp: Timestamp(date: Date()),
            status: "pending"
        )

        do {
            try ordersRef.setData(from: orderDetails) { error in
                if let error = error {
                    print("Error saving order: \(error.localizedDescription)")
                } else {
                    print("Order successfully saved!")
                }
            }
        } catch {
            print("Error encoding order: \(error.localizedDescription)")
        }
    }

    func fetchOrders(reservationId: String) {
        db.collection("business_users")
            .document(restaurantID)
            .collection("reservations")
            .document(reservationId)
            .collection("orders")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching orders: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.orders = documents.compactMap { document in
                    try? document.data(as: Order.self)
                }
            }
    }
    
    
    func deleteOrder(orderId: String, reservationId: String) {

        let orderRef = db.collection("business_users")
                         .document(restaurantID)
                         .collection("reservations")
                         .document(reservationId)
                         .collection("orders")
                         .document(orderId)

        orderRef.delete { error in
            if let error = error {
                print("Error deleting order: \(error.localizedDescription)")
            } else {
                print("Order successfully deleted!")
                // Optionally, remove the deleted order from the local orders array
                DispatchQueue.main.async {
                    self.orders.removeAll { $0.id == orderId }
                }
            }
        }
    }

}
