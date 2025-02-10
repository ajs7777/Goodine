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
            imageUrls: []
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
    
    private func fetchUserDetails() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            let document = try await db.collection("business_users").document(userId).getDocument()
            if let data = document.data() {
                self.restaurant = Restaurant(
                    id: data["id"] as? String ?? "",
                    ownerName: data["ownerName"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    type: data["type"] as? String ?? "",
                    city: data["city"] as? String ?? "",
                    state: data["state"] as? String ?? "",
                    address: data["address"] as? String ?? "",
                    zipcode: data["zipcode"] as? String ?? "",
                    averageCost: data["averageCost"] as? String ?? "",
                    openingTime: (data["openingTime"] as? Timestamp)?.dateValue() ?? Date(),  // Convert Timestamp to Date
                    closingTime: (data["closingTime"] as? Timestamp)?.dateValue() ?? Date(),  // Convert Timestamp to Date
                    imageUrls: data["imageUrls"] as? [String] ?? []
                )
            }
        } catch {
            print("Failed to fetch user details: \(error.localizedDescription)")
        }
    }

    
    func saveRestaurantDetails(_ restaurant: Restaurant, images: [UIImage]?) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        var updatedRestaurant = restaurant
        updatedRestaurant.id = userId

        // Upload multiple images to Firebase Storage
        var imageUrls: [String] = []
        if let images = images {
            for image in images {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    let storageRef = storage.reference().child("business_users/\(UUID().uuidString).jpg")
                    let _ = try await storageRef.putDataAsync(imageData, metadata: nil)
                    let url = try await storageRef.downloadURL()
                    imageUrls.append(url.absoluteString)
                }
            }
        }

        if !imageUrls.isEmpty {
            updatedRestaurant.imageUrls = imageUrls
        }

        try await db.collection("business_users").document(userId).setData([
            "id": updatedRestaurant.id,
            "ownerName": updatedRestaurant.ownerName,
            "name": updatedRestaurant.name,
            "type": updatedRestaurant.type,
            "city": updatedRestaurant.city,
            "state": updatedRestaurant.state,
            "address": updatedRestaurant.address,
            "zipcode": updatedRestaurant.zipcode,
            "averageCost": updatedRestaurant.averageCost,
            "openingTime": Timestamp(date: updatedRestaurant.openingTime),  // Convert Date to Timestamp
            "closingTime": Timestamp(date: updatedRestaurant.closingTime),  // Convert Date to Timestamp
            "imageUrls": updatedRestaurant.imageUrls
        ])
    }

}
