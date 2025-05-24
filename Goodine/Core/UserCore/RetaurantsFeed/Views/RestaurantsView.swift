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
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 15.0){
                KFImage(URL(string: restaurant.first?.imageUrls.first ?? ""))
                    .resizable()
                    .placeholder { ProgressView() }
                    .scaledToFill()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .clipped()
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
            .onAppear {
                if let restaurantID = restaurant.first?.id {
                    FavoritesManager.fetchFavoriteStatus(for: restaurantID) { status in
                        isFavorite = status
                    }
                }
            }

            
            Button(action: {
                if let restaurantID = restaurant.first?.id {
                        FavoritesManager.toggleFavorite(for: restaurantID) { newStatus in
                            isFavorite = newStatus
                        }
                    }
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(.orange)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(10)
                    .background(Circle().fill(.white))
            }
            .padding([.top, .trailing], 12)
        }
        .padding(.horizontal)
        
    }
    
    
    
}

#Preview {
    RestaurantsView( restaurant:
                        [ Restaurant(id: "", ownerName: "", name: "", type: "", city: "", state: "", address: "", zipcode: "", averageCost: "", openingTime: Date(), closingTime: Date(), imageUrls: [], currency: "INR", currencySymbol: "₹")], distanceInKm: 1.2
    )
}
