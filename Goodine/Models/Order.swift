import FirebaseFirestore
import FirebaseFirestoreSwift

struct Order: Identifiable, Codable {
    @DocumentID var id: String?  // Firestore-generated document ID
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
