//
//  AuthViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 03/02/25.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?  // Stores the logged-in Firebase user
    @Published var currentUser: User?               // Stores additional user data

    init() {
        self.userSession = Auth.auth().currentUser  // Check if a user is already logged in
        Task {
            await fetchUserData()
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
            try await signOut()  // Immediately sign out after account creation
        } catch {
            throw error
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = authResult.user  // Store user session
            await fetchUserData()
        } catch {
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

    // MARK: - Sign Out
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            throw error
        }
    }
}

