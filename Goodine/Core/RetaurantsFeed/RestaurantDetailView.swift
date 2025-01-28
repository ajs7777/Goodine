//
//  RestaurantDetailView.swift
//  Goodine
//
//  Created by Abhijit Saha on 28/01/25.
//

import SwiftUI

struct RestaurantDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var isFavorite: Bool = false
    
    var body: some View {
        ScrollView {
            VStack{
                restaurantsImages
                restaurantInfo
                locationTime
                featuresSection
            }
            .overlay(alignment: .top) {
                topBarIcons
            }
        }
        //.ignoresSafeArea()
        
        // book a table button works as sheet
        
        .overlay(alignment: .bottom) {
            ZStack {
                Color.white.ignoresSafeArea()
                    .frame(height: 100)
                Button {
                    
                } label: {
                    Text("Book a table")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
            }

        }
    }
}

#Preview {
    RestaurantDetailView()
}

extension RestaurantDetailView {
    
    private var topBarIcons : some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .tint(.black)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(.white)
                    )
                    .shadow(radius: 10)
            }

            Spacer()
            
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(10)
                .background(
                    Circle()
                        .fill(.white)
                )
                .onTapGesture {
                    isFavorite.toggle()
                }
                .shadow(radius: 10)
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(10)
                .background(
                    Circle()
                        .fill(.white)
                )
                .shadow(radius: 10)
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var restaurantsImages : some View {
        TabView {
            ForEach(0..<5) { image in
                Image("restaurant-2")
            }
            
        }
        .frame(height: 220)
        .tabViewStyle(PageTabViewStyle())
    }
    
    private var restaurantInfo : some View {
        VStack(alignment: .leading, spacing: 8){
            //open /c lose
            HStack{
                Text("Open Now")
                    .foregroundStyle(.black.opacity(0.8))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(7)
                    .background(.openGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer()

            }
            
            //Hotel name
            Text("Limelight - Royal Orchid Hotel")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack{
                VStack(alignment: .leading){
                    Text("Continental | Indian | Chinese")
                    Text("Indiranagar | 2 Km")
                        .foregroundStyle(.secondary)
                 }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8.0){
                    HStack(alignment: .center, spacing: 3.0) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.footnote)
                        Text("4.5(3k Ratings)")
                    }
                    .font(.callout)
                    
                    Text("₹ 2000 for two")
                        .font(.callout)
                 }
            }
            .padding(.bottom)
            
            Divider()
        }
        .padding(.top, 8)
        .padding(.horizontal)
    }
    
    private var locationTime: some View {
        VStack(alignment: .leading, spacing: 20.0){
            Text("Location")
                .font(.title)
                .fontWeight(.bold)
            
            //Hotel Address
            HStack(alignment: .top){
                Image(systemName: "location.circle")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("No.1, golf Avenue, HAL Old Airport Rd, Indiranagar, Bengaluru, Karnataka")
                Spacer()
            }
            
            //timings
            HStack(alignment: .top){
                Image(systemName: "clock")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("12:00 PM - 11:00 PM")
                Spacer()
            }
            
            Divider()
        }
        .padding()
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20.0){
            Text("Features")
                .font(.title)
                .fontWeight(.bold)
            
            //Features
            HStack{
                Text("Reservation Available")
                    .fontWeight(.medium)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text("Parking Available")
                    .fontWeight(.medium)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 150)
    }
}
