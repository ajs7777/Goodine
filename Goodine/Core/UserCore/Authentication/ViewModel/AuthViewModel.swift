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
    @Published var userdata: GoodineUser? = nil
    @Published var isLoading = true
    
    private var db = Firestore.firestore()
    private let storage = Storage.storage()
    
    init() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.goodineUser = user
            
            if let user = user {
                Task {
                    try? await user.reload()
                    if user.isEmailVerified {
                        self.goodineUser = user
                        await self.fetchUserData()
                    }
                    else {
                        self.userdata = nil
                        self.isLoading = false
                        self.goodineUser = nil
                        try? Auth.auth().signOut() // Sign out unverified user
                    }
                }
            } else {
                self.userdata = nil
                self.isLoading = false
            }
        }
    }
    
    
    func waitForEmailVerification(email: String, password: String, interval: TimeInterval = 3.0, timeout: TimeInterval = 180.0) async -> Bool {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                try await result.user.reload()

                if result.user.isEmailVerified {
                    self.goodineUser = result.user
                    await fetchUserData()
                    return true
                } else {
                    try? Auth.auth().signOut()
                }
            } catch {
                print("Error verifying email: \(error.localizedDescription)")
                return false
            }

            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }

        return false
    }

    
    func createUser(email: String, password: String, fullName: String, phoneNumber: String) async throws {
        do {
            // Create user
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Send verification email
            if let user = Auth.auth().currentUser {
                try await user.sendEmailVerification()
                try? Auth.auth().signOut() // ❗Sign out immediately after sending verification
            }
            
            // Store user data in Firestore
            let userId = result.user.uid
            let newUser = GoodineUser(
                id: userId,
                fullName: fullName,
                profileImageURL: nil,
                phoneNumber: phoneNumber
            )
            
            try db.collection("users").document(userId).setData(from: newUser)
            
            // Don't call fetchUserData yet — wait until they verify and log in
            self.goodineUser = nil
            self.userdata = nil
            
        } catch {
            print("Error creating user: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            guard result.user.isEmailVerified else {
                try? Auth.auth().signOut()
                throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Email not verified. Please check your inbox."])
            }
            
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
    
    func resetPassword(email: String) async {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("Password reset email sent.")
        } catch {
            print("Failed to send password reset email: \(error.localizedDescription)")
        }
    }
    
    func resendVerificationEmail() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user found. Please sign in first."])
        }
        
        do {
            try await user.sendEmailVerification()
        } catch {
            print("Failed to resend verification email: \(error.localizedDescription)")
            throw error
        }
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
                    profileImageURL: data["profileImageURL"] as? String,
                    phoneNumber: data["phoneNumber"] as? String ?? ""
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
    
    func updateUserData(fullName: String, phoneNumber: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let updates: [String: Any] = [
            "fullName": fullName,
            "phoneNumber": phoneNumber
        ]
        
        do {
            try await db.collection("users").document(uid).updateData(updates)
            await fetchUserData() // Refresh local state
        } catch {
            print("Failed to update user data: \(error.localizedDescription)")
        }
    }
    
}
