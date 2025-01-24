//
//  RestaurantsFeedView.swift
//  Goodine
//
//  Created by Abhijit Saha on 22/01/25.
//

import SwiftUI

struct RestaurantsFeedView: View {
    
    @State private var selectedPage = 0
    
    var body: some View {
        VStack {
            discountSection
        }
    }
}

#Preview {
    RestaurantsFeedView()
}

extension RestaurantsFeedView {
    private var categoriesSextion : some View {
        Grid(horizontalSpacing: 35, verticalSpacing: 10) {
                ForEach(0..<2) { row in
                    GridRow {
                        ForEach(0..<4) { column in
                            VStack{
                                Circle()
                                    .fill(Color.gray)
                                    .frame(width: 60, height: 60)
                                Text("Category")
                                    .font(.footnote)
                            }
                        }
                    }
                }
        }
        .padding()
       
    }
    private var discountSection: some View {
        VStack {
            TabView(selection: $selectedPage) {
                ForEach(0..<3) { index in
                    DiscountCardView()
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 160)
            
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Capsule()
                        .fill(selectedPage == index ? Color.black.opacity(0.8) : Color.gray.opacity(0.3))
                        .frame(width: selectedPage == index ? 25 : 10, height: 5)
                }
            }
        }
    }
}
