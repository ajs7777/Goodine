//
//  RestaurantsView.swift
//  Goodine
//
//  Created by Abhijit Saha on 28/01/25.
//

import SwiftUI
import Kingfisher

struct RestaurantsView: View {
    
    @State var isFavorite: Bool = false
    let restaurant: [Restaurant]
    
    var body: some View {
        VStack(spacing: 15.0){
            
            KFImage(URL(string: restaurant.first?.imageUrls.first ?? ""))
                .resizable()
                .placeholder {
                    ProgressView() // Show loading indicator
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
                        Text("4.5")
                            .foregroundStyle(.primary)
                            .font(.callout)
                            .bold()
                    }
                    Text("0.9 Km")
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
                .foregroundStyle(.red)
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
                    isFavorite.toggle()
                }
            
        }
        
    }
}

#Preview {
    RestaurantsView( restaurant:
                        [ Restaurant(id: "", ownerName: "", name: "", type: "", city: "", state: "", address: "", zipcode: "", averageCost: "", openingTime: Date(), closingTime: Date(), imageUrls: [], currency: "INR", currencySymbol: "₹")]
    )
}
