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
    
    @Published var goodineUser: User?
    @Published var userdata: GoodineUser?
    @Published var isLoading = true
    
    private var db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {
        Task {
            await fetchUserData()
        }
    }
    
    func createUser(email: String, password: String, fullName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.goodineUser = result.user
            
            let userId = result.user.uid
            let newUser = GoodineUser(
                id: userId,
                fullName: fullName,
                profileImageURL: nil // New user doesn't have profile picture yet
            )
            
            try db.collection("users").document(userId).setData(from: newUser)
            await fetchUserData()
        } catch {
            print("Error creating user: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.goodineUser = result.user
            await fetchUserData()
        } catch {
            print("Error signing in: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        self.goodineUser = nil
        self.userdata = nil
    }
    
    func fetchUserData() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            isLoading = false
            return
        }
        
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            if let data = document.data() {
                self.userdata = GoodineUser(
                    id: document.documentID, // ✅ Use Firestore document ID as id
                    fullName: data["fullName"] as? String ?? "",
                    profileImageURL: data["profileImageURL"] as? String
                )
                self.isLoading = false
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        } catch {
            print("Failed to fetch user data: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    // Upload profile image
    func uploadProfileImage(_ image: UIImage) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        let storageRef = storage.reference().child("profile_images/\(uid).jpg")
        
        do {
            _ = try await storageRef.putDataAsync(imageData)
            let downloadURL = try await storageRef.downloadURL()
            
            try await db.collection("users").document(uid).updateData([
                "profileImageURL": downloadURL.absoluteString
            ])
            
            // Update local user data
            await fetchUserData()
            
        } catch {
            print("Failed to upload profile image: \(error.localizedDescription)")
        }
    }
}
