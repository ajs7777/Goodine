//
//  DiscountCardView.swift
//  Goodine
//
//  Created by Abhijit Saha on 22/01/25.
//

import SwiftUI

struct DiscountCardView: View {
    let imageName: String
    let subtitle: String
    let description: String
    let gradient : Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background image
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .clipped()
                .overlay(
                    LinearGradient(colors: [gradient.opacity(0.3), gradient], startPoint: .trailing, endPoint: .leading)
                )
                .cornerRadius(12)
            
            // Content on top
            VStack(alignment: .leading, spacing: 6) {
                    Text(subtitle)
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                    Text(description)
                        .font(.headline)
                        .foregroundColor(.white)
                
                 Text("Book a table")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .bold()
                        .padding(10)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                
            }
            .padding()
            .padding(.horizontal, 5)
        }
        .padding(.horizontal)
    }
}
