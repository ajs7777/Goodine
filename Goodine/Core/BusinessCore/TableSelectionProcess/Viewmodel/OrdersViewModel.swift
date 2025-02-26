//
//  OrdersViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 26/02/25.
//

import FirebaseFirestore
import Foundation

class OrdersViewModel: ObservableObject {
    
    private let db = Firestore.firestore()

    func saveOrderToFirestore(selectedItems: [String: Int], menuItems: [MenuItem]) {
        guard !selectedItems.isEmpty else {
            print("❌ No items selected for order.")
            return
        }

        // Step 1: Get the business ID
        db.collection("business_users").getDocuments { (snapshot, error) in
            if let error = error {
                print("❌ Error fetching business ID: \(error.localizedDescription)")
                return
            }
            
            guard let businessDocs = snapshot?.documents,
                  let businessID = businessDocs.first?.documentID else {
                print("❌ No business found.")
                return
            }
            
            print("✅ Found Business ID: \(businessID)")
            
            // Step 2: Get the active reservation (for today)
            let today = Calendar.current.startOfDay(for: Date())
            
            self.db.collection("business_users")
                .document(businessID)
                .collection("reservations")
                .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: today)) // Today's reservations
                .order(by: "timestamp", descending: true)
                .limit(to: 1)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("❌ Error fetching reservation ID: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let reservationDocs = snapshot?.documents,
                          let reservationID = reservationDocs.first?.documentID else {
                        print("❌ No active reservations found for today.")
                        return
                    }
                    
                    print("✅ Found Reservation ID: \(reservationID)")
                    
                    // Step 3: Prepare order details with full item information
                    var orderedItems: [[String: Any]] = []
                    
                    for (itemID, quantity) in selectedItems {
                        if let menuItem = menuItems.first(where: { $0.id == itemID }) {
                            let itemData: [String: Any] = [
                                "item_id": itemID,
                                "name": menuItem.foodname,
                                "price": menuItem.foodPrice,
                                "quantity": quantity,
                                "image_url": menuItem.foodImage ?? "",
                                "isVeg": menuItem.veg
                            ]
                            orderedItems.append(itemData)
                        }
                    }
                    
                    let orderData: [String: Any] = [
                        "timestamp": Timestamp(date: Date()),
                        "items": orderedItems
                    ]

                    // Step 4: Save the order in Firestore
                    self.db.collection("business_users")
                        .document(businessID)
                        .collection("reservations")
                        .document(reservationID)
                        .collection("orders")
                        .addDocument(data: orderData) { error in
                            if let error = error {
                                print("❌ Error saving order: \(error.localizedDescription)")
                            } else {
                                print("🎉 Order placed successfully under Business ID: \(businessID), Reservation ID: \(reservationID)!")
                            }
                        }
                }
        }
    }
}

