//
//  RestaurantProfile.swift
//  Goodine
//
//  Created by Abhijit Saha on 04/02/25.
//

import SwiftUI
import Kingfisher

struct RestaurantProfile: View {
    @Environment(\.dismiss) var dismiss
    @State var isFavorite: Bool = false
    @State var showEditProfile : Bool = false
    @EnvironmentObject var viewModel : AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack{
                restaurantsImages
                restaurantInfo
                locationTime
                featuresSection
                
                Button{
                    Task{
                        try await viewModel.signOut()
                    }
                }label: {
                    Text("Log Out")
                        .foregroundStyle(.red)
                }
                .padding(.bottom, 120)
            }
            
        }
        .ignoresSafeArea()
        // book a table button works as sheet
        .sheet(isPresented: $showEditProfile, content: {
            RestaurantsDetailsForm()
        })
        .task {
            if let userId = viewModel.userSession?.uid {
                await viewModel.fetchUserRestaurants(userId: userId)
            }
        }

        
    }
}

#Preview {
    RestaurantProfile()
}


extension RestaurantProfile {
        
    private var restaurantsImages : some View {
        TabView {
            ForEach(viewModel.restaurants) { restaurant in
                if let imageUrls = restaurant.imageURLs, !imageUrls.isEmpty {
                    ForEach(imageUrls, id: \.self) { imageUrl in
                        KFImage(URL(string: imageUrl))
                    }
                        
                }
                
            }
            
        }
        .frame(height: 250)
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
                Button {
                    showEditProfile.toggle()
                } label: {
                    Text("Edit Profile")
                        .font(.subheadline)
                        
                }
                .buttonStyle(BorderedButtonStyle())

            }
            
            //Hotel name
            Text(viewModel.restaurants.first?.restaurantName ?? "")
                .foregroundStyle(.mainbw)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack{
                VStack(alignment: .leading){
                    Text(viewModel.restaurants.first?.restaurantType ?? "")
                        .foregroundStyle(.mainbw)
                    Text("\(viewModel.restaurants.first?.restaurantCity ?? "") | 2 Km")
                        .foregroundStyle(.secondary)
                 }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8.0){
                    HStack(alignment: .center, spacing: 3.0) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.footnote)
                        Text("4.5(3k Ratings)")
                            .foregroundStyle(.mainbw)
                    }
                    .font(.callout)
                    
                    Text("₹ \(viewModel.restaurants.first?.restaurantAverageCost ?? "") for two")
                        .foregroundStyle(.mainbw)
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
                .foregroundStyle(.mainbw)
                .font(.title)
                .fontWeight(.bold)
            
            //Hotel Address
            HStack(alignment: .top, spacing: 20.0){
                Image(systemName: "location.circle")
                    .foregroundStyle(.mainbw)
                    .font(.title2)
                    .fontWeight(.medium)
                Text(viewModel.restaurants.first?.restaurantAddress ?? "")
                    .foregroundStyle(.mainbw)
                    .font(.subheadline)
                Spacer()
            }
            
            //timings
            HStack(alignment: .top, spacing: 20.0){
                Image(systemName: "clock")
                    .foregroundStyle(.mainbw)
                    .font(.title2)
                    .fontWeight(.medium)
                Text("\(viewModel.restaurants.first?.startTime.formattedTime() ?? Date().formattedTime()) - \(viewModel.restaurants.first?.endTime.formattedTime() ?? Date().formattedTime())")
                    .foregroundStyle(.mainbw)
                Spacer()
            }
            
            Divider()
        }
        .padding()
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20.0){
            Text("Features")
                .foregroundStyle(.mainbw)
                .font(.title)
                .fontWeight(.bold)
            
            //Features
            HStack{
                Text("Reservation Available")
                    .foregroundStyle(.mainbw)
                    .fontWeight(.medium)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text("Parking Available")
                    .foregroundStyle(.mainbw)
                    .fontWeight(.medium)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
}

extension Date {
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" // 12-hour format with AM/PM
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
}

