//
//  MustTryPlaces.swift
//  Goodine
//
//  Created by Abhijit Saha on 25/01/25.
//

import SwiftUI

struct MustTryPlaces: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Must Try Places")
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12.0) {
                    ForEach(0..<10) { _ in
                        imageSection
                    }
                    
                } .padding(.horizontal)
            }
        }
        .padding(.top)
        
    }
}

#Preview {
    MustTryPlaces()
}

extension MustTryPlaces {
    var imageSection: some View {
        Image("Restaurant-1")
            .resizable()
            .scaledToFill()
            .frame(width: 170, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                ZStack(alignment: .bottomLeading) {
                    Color.black.opacity(0.2)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    LinearGradient(colors: [.black.opacity(0), .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    //text
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
    }
}
