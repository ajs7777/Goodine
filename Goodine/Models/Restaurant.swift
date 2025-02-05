import Foundation

struct Restaurant: Identifiable, Codable {
    var id: String = UUID().uuidString
    var restaurantName: String
    var restaurantType: String
    var restaurantAddress: String
    var restaurantState: String
    var restaurantCity: String
    var restaurantZipCode: String
    var restaurantAverageCost: String
    var startTime: Date
    var endTime: Date
}