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
    @Published var errorMessage: String?
    @Published var emailNotVerified: Bool = false
    @Published var isCheckingEmailVerification = false
    
    private var db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init(){
        Task{
            fetchBusinessDetails()
        }
        Task{
            await fetchAllRestaurants()
        }
        Task{
            checkUserAuthentication
        }
    }
    
    func checkUserAuthentication() async {
        guard ((Auth.auth().currentUser?.uid) != nil) else {
             isLoading = false
             return
         }
         
          fetchBusinessDetails()
     }
    
    func signUp(email: String, password: String, name : String, type : String, city : String, address : String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.businessUser = result.user
        
        try await result.user.sendEmailVerification()
        
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
            imageUrls: [],
            currency: "INR",
            currencySymbol: "₹"
        )
        
        try db.collection("business_users").document(userId).setData(from: newRestaurant)
    }
    
    func signIn(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            guard result.user.isEmailVerified else {
                self.emailNotVerified = true
                self.errorMessage = "Please verify your email before logging in."
                try? Auth.auth().signOut()
                
                // Start automatic email verification check
                checkEmailVerificationPeriodically()
                return
            }
            
            self.businessUser = result.user
            fetchBusinessDetails()
        } catch let error as NSError {
            DispatchQueue.main.async {
                switch error.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    self.errorMessage = "Incorrect password. Please try again."
                case AuthErrorCode.invalidEmail.rawValue:
                    self.errorMessage = "Invalid email format. Please enter a valid email."
                case AuthErrorCode.userNotFound.rawValue:
                    self.errorMessage = "No account found with this email. Please check or sign up."
                default:
                    self.errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    
    func signOut() {
        try? Auth.auth().signOut()
        self.businessUser = nil
        self.restaurant = nil
    }
    
    func resendVerificationEmail() async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await user.sendEmailVerification()
        self.errorMessage = "Verification email sent. Please check your inbox."
    }
    
    
    /// Automatically checks email verification status every 5 seconds
    func checkEmailVerificationPeriodically() {
        guard let user = Auth.auth().currentUser else { return }
        
        self.isCheckingEmailVerification = true
        Task {
            while self.emailNotVerified {
                do {
                    try await user.reload() // Refresh user info
                    if user.isEmailVerified {
                        DispatchQueue.main.async {
                            self.emailNotVerified = false
                            self.errorMessage = nil
                            self.businessUser = user
                            self.fetchBusinessDetails()
                        }
                        return
                    }
                } catch {
                    print("Error reloading user: \(error.localizedDescription)")
                }
                try await Task.sleep(nanoseconds: 5_000_000_000) // Wait 5 seconds before checking again
            }
        }
    }
    
    func refreshEmailVerification() async {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.reload()
            if user.isEmailVerified {
                DispatchQueue.main.async {
                    self.emailNotVerified = false
                    self.errorMessage = nil
                    self.businessUser = user
                    self.fetchBusinessDetails()
                }
            }
        } catch {
            print("Error refreshing email verification: \(error.localizedDescription)")
        }
    }
    
    func resetPassword(email: String) async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            DispatchQueue.main.async {
                self.errorMessage = "Password reset email sent. Please check your inbox."
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to send reset email: \(error.localizedDescription)"
            }
        }
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
                        imageUrls: data["imageUrls"] as? [String] ?? [],
                        currency: data["currency"] as? String ?? "INR",
                        currencySymbol: data["currencySymbol"] as? String ?? "₹"
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
            "imageUrls": updatedRestaurant.imageUrls,
            "currency": updatedRestaurant.currency,
            "currencySymbol": updatedRestaurant.currencySymbol
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
                    imageUrls: data["imageUrls"] as? [String] ?? [],
                    currency: data["currency"] as? String ?? "INR",
                    currencySymbol: data["currencySymbol"] as? String ?? "₹"
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
