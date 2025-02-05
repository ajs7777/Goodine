//
//  Restaurant.swift
//  Goodine
//
//  Created by Abhijit Saha on 04/02/25.
//


import Foundation
import FirebaseFirestore

struct Restaurant: Identifiable, Codable {
    @DocumentID var id: String?
    var restaurantName: String
    var restaurantType: String
    var restaurantAddress: String
    var restaurantState: String
    var restaurantCity: String
    var restaurantZipCode: String
    var restaurantAverageCost: String
    var startTime: Date
    var endTime: Date
    var imageURLs : [String]?
}
