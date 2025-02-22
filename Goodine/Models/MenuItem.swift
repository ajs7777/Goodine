//
//  MenuItem.swift
//  Goodine
//
//  Created by Abhijit Saha on 19/02/25.
//

import Foundation

struct MenuItem : Identifiable, Codable {
    let id: String
    let foodname: String
    let foodDescription: String?
    let foodPrice: Int
    let foodQuantity: Int?
    var foodImage: String?
    var veg : Bool = false
}

