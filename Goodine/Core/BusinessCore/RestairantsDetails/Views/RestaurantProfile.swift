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
    @ObservedObject var businessAuthMV = BusinessAuthViewModel()
    @State var showEditProfile : Bool = false
    
    var body: some View {
        ScrollView {
            if let imageUrls = businessAuthMV.restaurant?.imageUrls, !imageUrls.isEmpty {
                TabView {
                    ForEach(imageUrls, id: \.self) { imageUrl in
                        AsyncImage(url: URL(string: imageUrl)) { phase in
                            if let image = phase.image {
                                image.resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .padding(.horizontal)
                            } else {
                                ProgressView()
                                    .frame(height: 250)
                            }
                        }
                    }
                }
                .frame(height: 250)
                .tabViewStyle(PageTabViewStyle()) // Adds swipe dots at the bottom
                .indexViewStyle(PageIndexViewStyle())
                .padding()
            } else {
                Image(systemName: "photo")
                    .frame(height: 250)
            }
            if let restaurant = businessAuthMV.restaurant {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
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
                                    .foregroundStyle(.mainbw)
                            }
                            .buttonStyle(BorderedButtonStyle())
                        }
                        
                        Text(restaurant.name)
                            .foregroundStyle(.mainbw)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(restaurant.type)
                                    .foregroundStyle(.mainbw)
                                Text("\(restaurant.city) | 2 Km")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 8.0) {
                                HStack(alignment: .center, spacing: 3.0) {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.footnote)
                                    Text("4.5(3k Ratings)")
                                        .foregroundStyle(.mainbw)
                                }
                                .font(.callout)
                                
                                Text("₹\(restaurant.averageCost) for two")
                                    .foregroundStyle(.mainbw)
                                    .font(.callout)
                            }
                        }
                        .padding(.bottom)
                        
                        Divider()
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 20.0) {
                        Text("Location")
                            .foregroundStyle(.mainbw)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(alignment: .top, spacing: 20.0) {
                            Image(systemName: "location.circle")
                                .foregroundStyle(.mainbw)
                                .font(.title2)
                                .fontWeight(.medium)
                            Text(restaurant.address)
                                .foregroundStyle(.mainbw)
                                .font(.subheadline)
                            Spacer()
                        }
                        
                        HStack(alignment: .top, spacing: 20.0) {
                            Image(systemName: "clock")
                                .foregroundStyle(.mainbw)
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text("\(restaurant.openingTime.formattedTime()) - \(restaurant.closingTime.formattedTime())")
                                .foregroundStyle(.mainbw)
                            
                            Spacer()
                        }
                        
                        Divider()
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 20.0) {
                        Text("Features")
                            .foregroundStyle(.mainbw)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
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
            } else {
                ProgressView()
                    
            }
            Button{
                Task{
                    try businessAuthMV.signOut()
                }
            }label: {
                Text("Log Out")
                    .foregroundStyle(.red)
            }
            .padding(.bottom, 120)
        }
//        .onAppear {
//            Task { await businessAuthMV.fetchUserDetails() }
//        }
        .ignoresSafeArea()
        .sheet(isPresented: $showEditProfile) {
            RestaurantsDetailsForm(businessAuthMV: businessAuthMV)
        }
    }
}

#Preview {
    RestaurantProfile()
}


extension Date {
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
}


