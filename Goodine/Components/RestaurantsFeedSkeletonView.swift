//
//  RestaurantsFeedSkeletonView.swift
//  Goodine
//
//  Created by Abhijit Saha on 27/05/25.
//

import SwiftUI
import Shimmer

struct RestaurantsFeedSkeletonView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20){
                HStack{
                    VStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 20)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 30)
                    }
                    Spacer()
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 55, height: 55)
                }
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                
                ForEach(0..<2) { _ in // 2 rows
                    HStack(spacing: 20) {
                        ForEach(0..<4) { _ in // 2 columns
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 75, height: 75)
                                
                            }
                        }
                    }
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 5)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 300, height: 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                
                ForEach(0..<10) { _ in
                    VStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxWidth: .infinity)
                            .frame(height: 170)
                        HStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 20)
                            Spacer()
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 20)
                        }
                    }
                }
                
            }
            .shimmering()
            .padding()
        }
    }
}

#Preview {
    RestaurantsFeedSkeletonView()
}
