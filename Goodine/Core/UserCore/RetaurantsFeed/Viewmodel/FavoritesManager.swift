//
//  FavoritesManager.swift
//  Goodine
//
//  Created by Abhijit Saha on 22/05/25.
//


import Firebase
import FirebaseFirestore
import FirebaseAuth

struct FavoritesManager {
    
    static func toggleFavorite(for restaurantID: String, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let favRef = db.collection("users").document(userID).collection("Favourites").document(restaurantID)
        
        favRef.getDocument { document, error in
            if let document = document, document.exists {
                // If it's already favorited, remove it
                favRef.delete { error in
                    if let error = error {
                        print("Error removing favourite: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(false) // Now it's not a favorite
                    }
                }
            } else {
                // Otherwise, add it as a favorite
                favRef.setData(["timestamp": Timestamp()]) { error in
                    if let error = error {
                        print("Error saving favourite: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true) // Now it's a favorite
                    }
                }
            }
        }
    }
    
    static func fetchFavoriteStatus(for restaurantID: String, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        let favRef = db.collection("users").document(userID).collection("Favourites").document(restaurantID)
        
        favRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
