//
//  User.swift
//  Goodine
//
//  Created by Abhijit Saha on 03/02/25.
//

import Foundation

struct GoodineUser : Identifiable, Codable {
    let id: String
    let fullName: String
    let profileImageURL : String?
}
