//
//  MustTryPlaces.swift
//  Goodine
//
//  Created by Abhijit Saha on 25/01/25.
//

import SwiftUI
import Kingfisher

struct MustTryPlaces: View {
    
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    let restaurant: Restaurant
    
    var body: some View {
        if let imageUrl = restaurant.imageUrls.first, let url = URL(string: imageUrl) {
            KFImage(url)
                .resizable()
                .placeholder {
                    ProgressView() // Show a loading indicator
                }
                .scaledToFill()
                .frame(width: 170, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    ZStack(alignment: .bottomLeading) {
                        Color.black.opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        LinearGradient(colors: [.black.opacity(0), .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        // Text overlay
                        VStack(alignment: .leading, spacing: 2.0) {
                            Text("10 New")
                                .font(.footnote)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            Text("Popular Cafes")
                                .font(.footnote)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                        .shadow(radius: 10)
                        .padding(.bottom, 12)
                        .padding(.leading, 10)
                    }
                }
        } else {
            Color.gray.opacity(0.3) // Placeholder if no image URL
                .frame(width: 170, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    MustTryPlaces(restaurant: Restaurant(
        id: "",
        ownerName: "",
        name: "Popular Café",
        type: "Cafe",
        city: "New York",
        state: "NY",
        address: "123 Main St",
        zipcode: "10001",
        averageCost: "₹500",
        openingTime: Date(),
        closingTime: Date(),
        imageUrls: ["https://example.com/image.jpg"],
        currency: "INR",
        currencySymbol: "₹"
    ))
}


