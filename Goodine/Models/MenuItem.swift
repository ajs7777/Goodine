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
    let foodQuantity: Int
    let foodImage: String?
    var veg : Bool = false
}


extension MenuItem {
    static var MockData : [MenuItem] = [
        .init(id: "1", foodname: "Veg Burger", foodDescription: "A juicy burger made with fresh vegetables", foodPrice: 100, foodQuantity: 1, foodImage: nil),
        .init(id: "2", foodname: "Non Veg Burger", foodDescription: "A juicy burger made with fresh vegetables", foodPrice: 150, foodQuantity: 1, foodImage: nil),
    ]
}
