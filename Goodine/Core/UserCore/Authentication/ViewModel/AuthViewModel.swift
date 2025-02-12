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
    
    @Published var goodineUser : User?
    @Published var userdata : GoodineUser?
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
            let newUser = GoodineUser(id: userId, fullName: fullName)
            
            try db.collection("users").document(userId).setData(from: newUser)
        } catch {
            print("error creating user: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.goodineUser = result.user
            await fetchUserData()
        } catch  {
            print("error signing in: \(error.localizedDescription)")
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
                    id: data["id"] as? String ?? "",
                    fullName: data["fullName"] as? String ?? ""
                )
                self.isLoading = false
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        } catch {
            print("Failed to fetch user data: \(error.localizedDescription)")
        }
    }
    
    //    func fetchUserData() {
    //        guard let userId = Auth.auth().currentUser?.uid else { return }
    //
    //        db.collection("users").document(userId).addSnapshotListener { documentSnapshot, error in
    //            if let error = error {
    //                print("Failed to fetch user data: \(error.localizedDescription)")
    //                return
    //            }
    //            guard let document = documentSnapshot, document.exists else { return }
    //
    //            let data = document.data()
    //            DispatchQueue.main.async {
    //                self.userdata = GoodineUser(
    //                    id: data?["id"] as? String ?? "",
    //                    fullName: data?["fullName"] as? String ?? ""
    //                )
    //            }
    //        }
    //    }
}

