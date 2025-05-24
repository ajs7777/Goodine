//
//  FavouriteRestaurantRow.swift
//  Goodine
//
//  Created by Abhijit Saha on 11/05/25.
//

import SwiftUI
import Kingfisher
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct FavouriteRestaurantRow: View {
    @State private var isFavorite: Bool = false
    let restaurant: [Restaurant]
    let distanceInKm: Double?
    
    var body: some View {
        HStack(spacing: 15.0){
            
            KFImage(URL(string: restaurant.first?.imageUrls.first ?? ""))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .scaledToFill()
                .frame(width: 85, height: 85)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(restaurant.first?.name ?? "")
                    .foregroundStyle(.mainbw)
                    .lineLimit(1)
                    .font(.headline)
                    .bold()
                HStack{
                    Text(restaurant.first?.city ?? "")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text("|")
                        .font(.footnote)
                        .foregroundStyle(.mainbw.opacity(0.3))
                    Text(String(format: "%.1f Km", distanceInKm ?? 0.0))
                        .foregroundStyle(.gray)
                        .font(.footnote)
                }
            }
            
             Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.orange)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .onTapGesture {
                            toggleFavorite()
                        }
                    
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        Text("No Ratings")
                            .foregroundStyle(.primary)
                            .font(.callout)
                            .bold()
                    }
                   
                }
            
        }
        .padding(.horizontal)
        .padding(.bottom)
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
    FavouriteRestaurantRow(restaurant:
                            [ Restaurant(id: "", ownerName: "", name: "", type: "", city: "", state: "", address: "", zipcode: "", averageCost: "", openingTime: Date(), closingTime: Date(), imageUrls: [], currency: "INR", currencySymbol: "₹")], distanceInKm: 1.2
    )
}
