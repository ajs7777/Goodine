//
//  Order.swift
//  Goodine
//
//  Created by Abhijit Saha on 27/02/25.
//

import Foundation
import Firebase
import FirebaseFirestore

struct Order: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var items: [String: OrderItem]
    var timestamp: Timestamp
    var status: String
}

struct OrderItem: Codable {
    var name: String
    var price: Double
    var quantity: Int
}
