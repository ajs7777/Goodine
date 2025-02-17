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
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    @State var showEditProfile : Bool = false
    
    var isOpen: Bool {
        guard let openingTime = businessAuthVM.restaurant?.openingTime,
              let closingTime = businessAuthVM.restaurant?.closingTime else { return false }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Extract hours and minutes from stored opening and closing times
        let openingComponents = calendar.dateComponents([.hour, .minute], from: openingTime)
        let closingComponents = calendar.dateComponents([.hour, .minute], from: closingTime)
        
        // Create opening and closing Date objects for today
        let todayOpening = calendar.date(bySettingHour: openingComponents.hour ?? 0,
                                         minute: openingComponents.minute ?? 0,
                                         second: 0, of: now) ?? now
        let todayClosing = calendar.date(bySettingHour: closingComponents.hour ?? 0,
                                         minute: closingComponents.minute ?? 0,
                                         second: 0, of: now) ?? now
        
        return now >= todayOpening && now <= todayClosing
    }

    var statusText: String {
        guard let openingTime = businessAuthVM.restaurant?.openingTime,
              let closingTime = businessAuthVM.restaurant?.closingTime else { return "Closed" }

        let now = Date()
        let calendar = Calendar.current
        
        let openingComponents = calendar.dateComponents([.hour, .minute], from: openingTime)
        let closingComponents = calendar.dateComponents([.hour, .minute], from: closingTime)

        let todayOpening = calendar.date(bySettingHour: openingComponents.hour ?? 0,
                                         minute: openingComponents.minute ?? 0,
                                         second: 0, of: now) ?? now
        let todayClosing = calendar.date(bySettingHour: closingComponents.hour ?? 0,
                                         minute: closingComponents.minute ?? 0,
                                         second: 0, of: now) ?? now
        
        let halfHourBeforeOpening = calendar.date(byAdding: .minute, value: -30, to: todayOpening) ?? todayOpening
        let halfHourBeforeClosing = calendar.date(byAdding: .minute, value: -30, to: todayClosing) ?? todayClosing

        if now >= halfHourBeforeOpening && now < todayOpening {
            return "Opens Soon"
        } else if now >= halfHourBeforeClosing && now < todayClosing {
            return "Closes Soon"
        } else if isOpen {
            return "Open Now"
        } else {
            return "Closed"
        }
    }
    
    var body: some View {
        ScrollView {
            if let imageUrls = businessAuthVM.restaurant?.imageUrls, !imageUrls.isEmpty {
                TabView {
                    ForEach(imageUrls, id: \.self) { imageUrl in
                        KFImage(URL(string: imageUrl)) // Using Kingfisher
                            .resizable()
                            .scaledToFill()
                            .frame(height: 270)
                            
                    }
                }
                .frame(height: 250)
                .tabViewStyle(PageTabViewStyle()) // Adds swipe dots at the bottom
                .indexViewStyle(PageIndexViewStyle())
            } else {
                Image(systemName: "photo")
                    .frame(height: 250)
            }
            if let restaurant = businessAuthVM.restaurant {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(statusText)
                                .foregroundStyle(statusText == "Closed" ? .white : statusText == "Closes Soon" ? .white : .black.opacity(0.8))
                                .font(.callout)
                                .fontWeight(.semibold)
                                .padding(7)
                                .padding(.horizontal, 3)
                                .background(
                                    statusText == "Open Now" ? .openGreen :
                                    statusText == "Opens Soon" ? .yellow :
                                    statusText == "Closes Soon" ? .orange : .red
                                )
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
                                if restaurant.averageCost != "" {
                                    Text("₹\(restaurant.averageCost ?? "") for two")
                                        .foregroundStyle(.mainbw)
                                        .font(.callout)
                                }
                                
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
                    businessAuthVM.signOut()
                }
            }label: {
                Text("Log Out")
                    .foregroundStyle(.red)
            }
            .padding(.bottom, 120)
        }
        .ignoresSafeArea()
        .scrollIndicators(.hidden)
        .sheet(isPresented: $showEditProfile) {
            RestaurantsDetailsForm(businessAuthVM: businessAuthVM)
        }
    }
}

#Preview {
    RestaurantProfile()
        .environmentObject(BusinessAuthViewModel())
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


