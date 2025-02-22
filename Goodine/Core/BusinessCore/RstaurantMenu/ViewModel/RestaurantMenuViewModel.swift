import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class RestaurantMenuViewModel: ObservableObject {
    @Published var items = [MenuItem]()
    private let db = Firestore.firestore()
    
    func fetchMenuItems() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged-in user")
            return
        }
        
        db.collection("business_users").document(userId).collection("menu").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching menu items: \(error)")
                return
            }
            
            if let documents = snapshot?.documents {
                self.items = documents.compactMap { doc in
                    try? doc.data(as: MenuItem.self)
                }
            }
        }
    }
    
    func saveItemToFirestore(_ item: MenuItem) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged-in user")
            return
        }
        
        let menuRef = db.collection("business_users").document(userId).collection("menu")
        menuRef.addDocument(data: [
            "foodname": item.foodname,
            "foodDescription": item.foodDescription ?? "",
            "foodPrice": item.foodPrice,
            "foodQuantity": item.foodQuantity,
            "foodImage": item.foodImage ?? "",
            "veg": item.veg
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Item added successfully")
            }
        }
    }
}