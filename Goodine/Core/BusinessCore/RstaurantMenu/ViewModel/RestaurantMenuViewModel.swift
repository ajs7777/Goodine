//
//  RestaurantMenuViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 21/02/25.
//


import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class RestaurantMenuViewModel: ObservableObject {
    @Published var items = [MenuItem]()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {
        self.fetchMenuItems()
    }
    
    func fetchMenuItems() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged-in user")
            return
        }
        
        db.collection("business_users").document(userId).collection("menu")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching menu items: \(error)")
                    return
                }
                
                if let documents = snapshot?.documents {
                    DispatchQueue.main.async {
                        self.items = documents.compactMap { doc in
                            let item = try? doc.data(as: MenuItem.self)
                            print("✅ Real-time update: \(item?.foodImage ?? "No Image")")
                            return item
                        }
                    }
                }
            }
    }

    
    func saveItemToFirestore(_ item: MenuItem, image: UIImage?) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged-in user")
            return
        }
        
        let menuRef = db.collection("business_users").document(userId).collection("menu").document(item.id) // 🔥 Keeps the same ID

        if let image = image {
            uploadImage(image, itemId: item.id) { imageUrl in
                var updatedItem = item
                updatedItem.foodImage = imageUrl
                do {
                    try menuRef.setData(from: updatedItem) // 🔥 Updates the existing document
                    print("Item updated successfully")
                } catch {
                    print("Error updating document: \(error)")
                }
            }
        } else {
            do {
                try menuRef.setData(from: item) // 🔥 Updates without changing the image
                print("Item updated successfully")
            } catch {
                print("Error updating document: \(error)")
            }
        }
    }



    
    func deleteItem(_ item: MenuItem) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged-in user")
            return
        }
        
        db.collection("business_users").document(userId).collection("menu").document(item.id).delete { error in
            if let error = error {
                print("Error deleting document: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.items.removeAll { $0.id == item.id }
                }
                print("Item deleted successfully")
            }
        }
    }
    
    private func uploadImage(_ image: UIImage, itemId: String, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to get image data")
            completion(nil)
            return
        }
        
        let storageRef = storage.reference().child("menu_images/\(itemId).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("❌ Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Error getting image URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let urlString = url?.absoluteString {
                    print("✅ Image uploaded successfully: \(urlString)")
                    completion(urlString)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func updateItemInFirestore(_ item: MenuItem, image: UIImage?) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No logged-in user")
            return
        }
        
        let menuRef = db.collection("business_users").document(userId).collection("menu").document(item.id)
        
        if let image = image {
            uploadImage(image, itemId: item.id) { imageUrl in
                guard let imageUrl = imageUrl else {
                    print("❌ Image upload failed")
                    return
                }
                
                var updatedItem = item
                updatedItem.foodImage = imageUrl
                
                do {
                    try menuRef.setData(from: updatedItem)
                    print("✅ Item updated successfully with image: \(imageUrl)")
                    
                    // 🔥 Refresh UI
                    DispatchQueue.main.async {
                        self.fetchMenuItems()
                    }
                    
                } catch {
                    print("❌ Error updating document: \(error)")
                }
            }
        } else {
            do {
                try menuRef.setData(from: item)
                print("✅ Item updated successfully without image")
                
                // 🔥 Refresh UI
                DispatchQueue.main.async {
                    self.fetchMenuItems()
                }
                
            } catch {
                print("❌ Error updating document: \(error)")
            }
        }
    }    
    
}
