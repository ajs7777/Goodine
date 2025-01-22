//
//  DiscountCardView.swift
//  Goodine
//
//  Created by Abhijit Saha on 22/01/25.
//

import SwiftUI

struct DiscountCardView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            // Background image
            Image("Discount-1") // Replace with your image asset name
                .resizable()
                .scaledToFill()
                .frame(height: 150) // Adjust the height as needed
                .clipped()
                .overlay(
                    LinearGradient(colors: [Color("darkblue").opacity(0.3), Color("darkblue")], startPoint: .trailing, endPoint: .leading)
                )
                .cornerRadius(12)
            
            // Content on top of the image
            VStack(alignment: .leading) {
                Text("Flat")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("50% off")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                Text("at BLR Brewing Co.")
                    .font(.headline)
                    .foregroundColor(.white)
                                
                Button(action: {
                    // Action to book a table
                }) {
                    Text("Book a table")
                        .font(.headline)
                        .bold()
                        .padding(10)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            .padding()
            .padding(.leading)
        }
        .padding()
    }
}

#Preview {
    DiscountCardView()
}
