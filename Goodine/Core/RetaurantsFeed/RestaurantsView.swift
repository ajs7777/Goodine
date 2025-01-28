//
//  RestaurantsView.swift
//  Goodine
//
//  Created by Abhijit Saha on 28/01/25.
//

import SwiftUI

struct RestaurantsView: View {
    
    @State var isFavorite: Bool = false
    
    var body: some View {
        VStack(spacing: 15.0){
            
            Image("restaurant-2")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            HStack {
                VStack(alignment: .leading) {
                    Text("Limelight - Royal Orchid Hotel")
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .font(.headline)
                        .bold()
                    Text("North Indian | Continental")
                        .foregroundStyle(.primary)
                        .font(.footnote)
                    Text("BTM Layout")
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
                    Text("₹2000 for two")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .overlay(alignment: .topTrailing) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(.primary)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(10)
                .background(
                    Circle()
                        .fill(.white)
                )
                .padding(30)
                .onTapGesture {
                    isFavorite.toggle()
                }
            
        }
    }
}

#Preview {
    RestaurantsView()
}
