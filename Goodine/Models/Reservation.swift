//
//  Reservation.swift
//  Goodine
//
//  Created by Abhijit Saha on 27/02/25.
//

import Foundation

struct Reservation: Identifiable, Codable {
    var id: String
    var tables: [Int]
    var seats: [Int: [Bool]]
    var peopleCount: [Int: Int]
    var timestamp: Date
    var billingTime: Date?
    var isPaid: Bool
    var userID: String?
    var restaurantID: String?
}
