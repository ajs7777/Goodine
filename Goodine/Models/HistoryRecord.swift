//
//  HistoryRecord.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/03/25.
//

import Foundation

 struct HistoryRecord: Identifiable, Codable {
        var id: String
        var tables: [Int]
        var seats: [Int: [Bool]]
        var peopleCount: [Int: Int]
        var timestamp: Date
        var billingTime: Date
    }
