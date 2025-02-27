//
//  OrdersViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 26/02/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []

    private let db = Firestore.firestore()

    func saveOrderToFirestore(
        reservationId: String,
        selectedItems: [String: Int],
        menuItems: [MenuItem]
    ) {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Ensure user is authenticated

        let ordersRef = db.collection("business_users")
                          .document(userId)
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
            userId: userId,
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
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("business_users")
            .document(userId)
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
}
