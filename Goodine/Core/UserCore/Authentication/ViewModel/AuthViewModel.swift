//
//  AuthViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 03/02/25.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import FirebaseStorage

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?  // Stores the logged-in Firebase user
    @Published var currentUser: User?               // Stores additional user data
    @Published var currentBusinessUser: BusinessUser?
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading = false

    init() {
        self.userSession = Auth.auth().currentUser  // Check if a user is already logged in
        Task {
            await fetchUserData()
        }
        Task {
            await fetchBusinessUserData()
        }
    }

    // MARK: - Create User
    func createUser(email: String, password: String, fullName: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = authResult.user  // Store user session
            
            // Save user info in Firestore
            let user = User(id: authResult.user.uid, fullName: fullName, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(authResult.user.uid).setData(encodedUser)
            //await fetchUserData()
            self.userSession = nil
            //try await signOut()  // Immediately sign out after account creation
        } catch {
            throw error
        }
    }
    
    func createBusinessUser(email: String, password: String, businessName: String) async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = authResult.user  // Store user session
            
            // Save user info in Firestore
            let businessUser = BusinessUser(id: authResult.user.uid, email: email, businessName: businessName)
            let encodedBusinessUser = try Firestore.Encoder().encode(businessUser)
            try await Firestore.firestore().collection("business_users").document(authResult.user.uid).setData(encodedBusinessUser)
            await fetchBusinessUserData()
            print("DEBUG: User created successfully!")
            try await signOut()  // Immediately sign out after account creation
        } catch {
            print("DUBUG: Error creating user: \(error)")
            throw error
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = authResult.user  // Store user session
            await fetchUserData()
            await fetchUserRestaurants(userId: authResult.user.uid)
        } catch {
            print("DEBUG: Error signing in user: \(error)")
            throw error            
        }
    }
    
    func businessSignIn(email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = authResult.user  // Store user session
            await fetchBusinessUserData()
        } catch {
            print("DEBUG: Error signing in user: \(error)")
            throw error
        }
    }

    // MARK: - Fetch User Data
    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("Error fetching user data: \(String(describing: self.currentUser))")
        
    }
    
    func fetchBusinessUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("business_users").document(uid).getDocument() else { return }
        self.currentBusinessUser = try? snapshot.data(as: BusinessUser.self)
        
        print("Error fetching user data: \(String(describing: self.currentBusinessUser))")
        
    }
    

    // MARK: - Sign Out
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.currentBusinessUser = nil
        } catch {
            throw error
        }
    }
    
    func saveRestaurantDetails(restaurant: Restaurant, images: [UIImage]) async throws {
        guard let userId = userSession?.uid else { return }

        
        isLoading = true  // Show loading indicator
        
        do {
                let imageURLs = try await uploadImages(images: images)  // Upload all images

        let restaurantData: [String: Any] = [
            "restaurantName": restaurant.restaurantName,
            "restaurantType": restaurant.restaurantType,
            "restaurantAddress": restaurant.restaurantAddress,
            "restaurantState": restaurant.restaurantState,
            "restaurantCity": restaurant.restaurantCity,
            "restaurantZipCode": restaurant.restaurantZipCode,
            "restaurantAverageCost": restaurant.restaurantAverageCost,
            "startTime": restaurant.startTime,
            "endTime": restaurant.endTime,
            "userId": userId, // Linking restaurant data to the logged-in user
            "imageURLs": imageURLs  // Store multiple image URLs in Firestore
        ]

        try await Firestore.firestore().collection("restaurants").document(userId).setData(restaurantData)
            
            isLoading = false  // Hide loading indicator
                    
                } catch {
                    isLoading = false
                    print("Error saving restaurant: \(error.localizedDescription)")
                    throw error
                }
    }
    

    // Fetch all restaurants
    func fetchRestaurants() async {
        do {
            let snapshot = try await Firestore.firestore().collection("restaurants").getDocuments()
            self.restaurants = snapshot.documents.compactMap { document in
                try? document.data(as: Restaurant.self)
            }
        } catch {
            print("Error fetching restaurants: \(error.localizedDescription)")
        }
    }

    // Fetch restaurants added by a specific user
    func fetchUserRestaurants(userId: String) async {
        do {
            let snapshot = try await Firestore.firestore()
                .collection("restaurants")
                .whereField("userId", isEqualTo: userId)
                .getDocuments()
            
            self.restaurants = snapshot.documents.compactMap { document in
                try? document.data(as: Restaurant.self)
            }
        } catch {
            print("Error fetching user-specific restaurants: \(error.localizedDescription)")
        }
    }
    
    func uploadImages(images: [UIImage]) async throws -> [String] {
        var imageURLs: [String] = []
        
        let storageRef = Storage.storage().reference()
        
        for image in images {
            guard let imageData = image.jpegData(compressionQuality: 0.7) else { continue }
            
            let imagePath = "restaurant_images/\(UUID().uuidString).jpg"
            let imageRef = storageRef.child(imagePath)
            
            let _ = try await imageRef.putDataAsync(imageData)  // Upload image
            let imageURL = try await imageRef.downloadURL()  // Get download URL
            
            imageURLs.append(imageURL.absoluteString)
        }
        
        return imageURLs
    }
    



}

