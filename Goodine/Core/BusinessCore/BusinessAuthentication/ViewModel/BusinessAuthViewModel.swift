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
    @Published var restaurant: Restaurant?
    @Published var allRestaurants: [Restaurant] = []
    @Published var isLoading = true
    
    private var db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init(){
        Task{
            fetchBusinessDetails()
        }
        Task{
            await fetchAllRestaurants()
        }
    }
    
    func signUp(email: String, password: String, name : String, type : String, city : String, address : String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.businessUser = result.user
        
        let userId = result.user.uid
        let newRestaurant = Restaurant(
            id: userId,
            ownerName: "",
            name: name,
            type: type,
            city: city,
            state: "",
            address: address,
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
        fetchBusinessDetails()
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.businessUser = nil
        self.restaurant = nil
    }
    
    func fetchBusinessDetails() {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        db.collection("business_users").document(userId).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Failed to fetch business details: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot, document.exists else { return }
            
            if let data = document.data() {
                DispatchQueue.main.async {
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
                        openingTime: (data["openingTime"] as? Timestamp)?.dateValue() ?? Date(),
                        closingTime: (data["closingTime"] as? Timestamp)?.dateValue() ?? Date(),
                        imageUrls: data["imageUrls"] as? [String] ?? []
                    )
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
        }
    }
    
    
    
    func saveRestaurantDetails(_ restaurant: Restaurant, images: [UIImage]?) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        var updatedRestaurant = restaurant
        updatedRestaurant.id = userId
        
        var imageUrls: [String] = updatedRestaurant.imageUrls
        
        // Upload new images and update Firestore
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
        
        updatedRestaurant.imageUrls = imageUrls
        
        try await db.collection("business_users").document(userId).setData([
            "id": updatedRestaurant.id,
            "ownerName": updatedRestaurant.ownerName,
            "name": updatedRestaurant.name,
            "type": updatedRestaurant.type,
            "city": updatedRestaurant.city,
            "state": updatedRestaurant.state,
            "address": updatedRestaurant.address,
            "zipcode": updatedRestaurant.zipcode,
            "averageCost": updatedRestaurant.averageCost ?? "",
            "openingTime": Timestamp(date: updatedRestaurant.openingTime),
            "closingTime": Timestamp(date: updatedRestaurant.closingTime),
            "imageUrls": updatedRestaurant.imageUrls
        ])
        
        // **Update @Published restaurant to trigger UI refresh**
        DispatchQueue.main.async {
            self.restaurant = updatedRestaurant
        }
    }
    
    
    func deleteImage(_ imageUrl: String) async {
        //guard let userId = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference(forURL: imageUrl)
        
        do {
            // Delete image from Firebase Storage
            try await storageRef.delete()
            
            // Remove image URL from Firestore
            if let index = restaurant?.imageUrls.firstIndex(of: imageUrl) {
                restaurant?.imageUrls.remove(at: index)
                if let updatedRestaurant = restaurant {
                    try await saveRestaurantDetails(updatedRestaurant, images: nil)
                }
            }
        } catch {
            print("Failed to delete image: \(error.localizedDescription)")
        }
    }
    
    func fetchAllRestaurants() async {
        isLoading = true
        do {
            let snapshot = try await db.collection("business_users").getDocuments()
            let restaurants = snapshot.documents.compactMap { document -> Restaurant? in
                let data = document.data()
                return Restaurant(
                    id: data["id"] as? String ?? "",
                    ownerName: data["ownerName"] as? String ?? "",
                    name: data["name"] as? String ?? "",
                    type: data["type"] as? String ?? "",
                    city: data["city"] as? String ?? "",
                    state: data["state"] as? String ?? "",
                    address: data["address"] as? String ?? "",
                    zipcode: data["zipcode"] as? String ?? "",
                    averageCost: data["averageCost"] as? String ?? "",
                    openingTime: (data["openingTime"] as? Timestamp)?.dateValue() ?? Date(),
                    closingTime: (data["closingTime"] as? Timestamp)?.dateValue() ?? Date(),
                    imageUrls: data["imageUrls"] as? [String] ?? []
                )
            }
            
            DispatchQueue.main.async {
                self.allRestaurants = restaurants
                self.isLoading = false
            }
        } catch {
            print("Error fetching restaurants: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
}
