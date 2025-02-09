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
    @EnvironmentObject var businessAuthMV : BusinessAuthViewModel
//    @EnvironmentObject var restaurantVM : RestaurantsDetailsViewModel
    @State var showEditProfile : Bool = false
    
    var body: some View {
        ScrollView {
                if let restaurant = businessAuthMV.restaurant {
                    VStack(alignment: .leading) {
                        TabView {
                            if restaurant.imageUrl.isEmpty {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                                    .foregroundStyle(.gray.opacity(0.6))
                            } else {
                                KFImage(URL(string: restaurant.imageUrl))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 250)
                                        .clipped()
                                
                            }
                        }
                        .frame(height: 250)
                        .tabViewStyle(PageTabViewStyle())
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
                        .onAppear {
                        Task { await businessAuthMV.fetchUserDetails() }
                    }
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
        .ignoresSafeArea()
        .sheet(isPresented: $showEditProfile) {
            RestaurantsDetailsForm()
        }
    }
}

#Preview {
    RestaurantProfile()
}

//extension RestaurantProfile {
    
//    private func restaurantImages(_ imageURLs: [String]) -> some View {
//        TabView {
//            if imageURLs.isEmpty {
//                Image(systemName: "photo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 50)
//                    .foregroundStyle(.gray.opacity(0.6))
//            } else {
//                ForEach(imageURLs, id: \.self) { imageUrl in
//                    KFImage(URL(string: imageUrl))
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: 250)
//                        .clipped()
//                }
//            }
//        }
//        .frame(height: 250)
//        .tabViewStyle(PageTabViewStyle())
//    }

//}

extension Date {
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
}


