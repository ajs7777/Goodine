//
//  Restaurant.swift
//  Goodine
//
//  Created by Abhijit Saha on 04/02/25.
//


import Foundation

struct Restaurant: Identifiable, Codable, Equatable {
    var id: String
    var ownerName: String
    var name: String
    var type: String
    var city: String
    var state: String
    var address: String
    var zipcode: String
    var averageCost: String?
    var openingTime: Date
    var closingTime: Date
    var imageUrls: [String]
    var currency: String
    var currencySymbol: String
    var features: [String] = []
    
}
