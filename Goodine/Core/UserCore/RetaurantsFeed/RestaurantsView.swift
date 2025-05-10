//
//  RestaurantsView.swift
//  Goodine
//
//  Created by Abhijit Saha on 28/01/25.
//

import SwiftUI
import Kingfisher
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct RestaurantsView: View {
    
    @State private var isFavorite: Bool = false
    let restaurant: [Restaurant]
    let distanceInKm: Double?
    
    var body: some View {
        VStack(spacing: 15.0){
            
            KFImage(URL(string: restaurant.first?.imageUrls.first ?? ""))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            HStack {
                VStack(alignment: .leading) {
                    Text(restaurant.first?.name ?? "")
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .font(.headline)
                        .bold()
                    Text(restaurant.first?.type ?? "")
                        .foregroundStyle(.primary)
                        .font(.footnote)
                    Text(restaurant.first?.city ?? "")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text("No Ratings")
                            .foregroundStyle(.primary)
                            .font(.callout)
                            .bold()
                    }
                    Text(String(format: "%.1f Km", distanceInKm ?? 0.0))
                        .foregroundStyle(.gray)
                        .font(.footnote)
                    Text("₹\(restaurant.first?.averageCost ?? "") for two")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .overlay(alignment: .topTrailing) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(.orange)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(10)
                .background(
                    Circle()
                        .fill(.white)
                )
                .padding(.trailing, 26)
                .padding(.top, 10)
                .onTapGesture {
                    toggleFavorite()
                }
        }
        .onAppear {
            fetchFavoriteStatus()
        }
    }
    
    private func toggleFavorite() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        guard let restaurantID = restaurant.first?.id else {
            print("Invalid restaurant")
            return
        }

        let db = Firestore.firestore()
        let favRef = db.collection("users").document(userID).collection("Favourites").document(restaurantID)

        if isFavorite {
            favRef.delete { error in
                if let error = error {
                    print("Error removing favourite: \(error.localizedDescription)")
                } else {
                    isFavorite = false
                }
            }
        } else {
            favRef.setData(["timestamp": Timestamp()]) { error in
                if let error = error {
                    print("Error saving favourite: \(error.localizedDescription)")
                } else {
                    isFavorite = true
                }
            }
        }
    }

    private func fetchFavoriteStatus() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        guard let restaurantID = restaurant.first?.id else {
            print("Invalid restaurant")
            return
        }

        let db = Firestore.firestore()
        let favRef = db.collection("users").document(userID).collection("Favourites").document(restaurantID)

        favRef.getDocument { document, error in
            if let document = document, document.exists {
                isFavorite = true
            } else {
                isFavorite = false
            }
        }
    }
}


#Preview {
    RestaurantsView( restaurant:
                        [ Restaurant(id: "", ownerName: "", name: "", type: "", city: "", state: "", address: "", zipcode: "", averageCost: "", openingTime: Date(), closingTime: Date(), imageUrls: [], currency: "INR", currencySymbol: "₹")], distanceInKm: 1.2
    )
}
