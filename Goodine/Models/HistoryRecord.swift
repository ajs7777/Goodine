 struct HistoryRecord: Identifiable, Codable {
        var id: String
        var tables: [Int]
        var seats: [Int: [Bool]]
        var peopleCount: [Int: Int]
        var timestamp: Date
        var billingTime: Date
    }