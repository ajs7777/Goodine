//
//  BusinessAuthViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 07/02/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@MainActor
class BusinessAuthViewModel: ObservableObject {
    
    @Published var businessUser: User?
    @Published var isNewUser = false
    @Published var restaurant: Restaurant?
    private var db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init(){
        self.businessUser = Auth.auth().currentUser
        Task{
            await fetchUserDetails()
        }
    }
    
    func signUp(email: String, password: String, ownerName: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.businessUser = result.user
        self.isNewUser = true
        
        let userId = result.user.uid
        let newRestaurant = Restaurant(
            id: userId,
            ownerName: ownerName,
            name: "",
            type: "",
            city: "",
            state: "",
            address: "",
            zipcode: "",
            averageCost: "",
            openingTime: Date(),
            closingTime: Date(),
            imageUrl: ""
        )
        
        try db.collection("business_users").document(userId).setData(from: newRestaurant)
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.businessUser = result.user
        await fetchUserDetails()
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        self.businessUser = nil
        self.restaurant = nil
    }
    
    func fetchUserDetails() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let document = try await db.collection("business_users").document(userId).getDocument()
            self.restaurant = try document.data(as: Restaurant.self)
        } catch {
            print("Failed to fetch user details: \(error.localizedDescription)")
        }
    }
    
    func saveRestaurantDetails(_ restaurant: Restaurant, image: UIImage?) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        var updatedRestaurant = restaurant
        updatedRestaurant.id = userId
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            let storageRef = storage.reference().child("business_users/\(userId).jpg")
            let _ = try await storageRef.putDataAsync(imageData, metadata: nil)
            let url = try await storageRef.downloadURL()
            updatedRestaurant.imageUrl = url.absoluteString
        }
        
        try db.collection("business_users").document(userId).setData(from: updatedRestaurant)
    }
}
