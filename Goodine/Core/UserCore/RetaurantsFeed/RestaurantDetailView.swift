//
//  RestaurantDetailView.swift
//  Goodine
//
//  Created by Abhijit Saha on 28/01/25.
//

import SwiftUI
import Kingfisher

struct RestaurantDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var isFavorite: Bool = false
    @State var showBookingSheet: Bool = false
    
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    
    let restaurant: Restaurant
    
    var isOpen: Bool {
        guard let openingTime = businessAuthVM.restaurant?.openingTime,
              let closingTime = businessAuthVM.restaurant?.closingTime else { return false }

        let now = Date()
        return now >= openingTime && now <= closingTime
    }

    var statusText: String {
        guard let openingTime = businessAuthVM.restaurant?.openingTime,
              let closingTime = businessAuthVM.restaurant?.closingTime else { return "Closed" }

        let now = Date()
        let halfHourBeforeOpening = Calendar.current.date(byAdding: .minute, value: -30, to: openingTime) ?? openingTime
        let halfHourBeforeClosing = Calendar.current.date(byAdding: .minute, value: -30, to: closingTime) ?? closingTime

        if now >= halfHourBeforeOpening && now < openingTime {
            return "Opens Soon"
        } else if now >= halfHourBeforeClosing && now < closingTime {
            return "Closes Soon"
        } else if isOpen {
            return "Open"
        } else {
            return "Closed"
        }
    }

    
    
    
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
        .onAppear {
            Task{
                await businessAuthVM.fetchAllRestaurants()
            }
        }
        // book a table button works as sheet
        .sheet(isPresented: $showBookingSheet, content: {
            BookATableView()
        })
        .overlay(alignment: .bottom) {
            ZStack {
                Color.mainInvert.ignoresSafeArea()
                    .frame(height: 80)
                Button {
                    showBookingSheet.toggle()
                } label: {
                    Text("Book a table")
                        .font(.title3)
                        .goodineButtonStyle(.mainbw)
                }
                .padding(.horizontal)
            }

        }
    }
}

#Preview {
    RestaurantDetailView( restaurant: Restaurant(id: "", ownerName: "", name: "Limelight - Orchid Heritage", type: "Indian, Chinese", city: "Agartala", state: "", address: "VN lane 1 - Agartala, Tripura 799009", zipcode: "", averageCost: "", openingTime: Date(), closingTime: Date(), imageUrls: []))
        .environmentObject(BusinessAuthViewModel())
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
                .foregroundStyle(.black)
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
                .foregroundStyle(.black)
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
    
    private var restaurantsImages: some View {
        TabView {
            ForEach(restaurant.imageUrls, id: \.self) { imageUrl in
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .placeholder {
                        ProgressView() // Show loading indicator
                    }
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: 250)
                    .clipped()
            }
        }
        .frame(height: 250)
        .tabViewStyle(PageTabViewStyle())
    }
    
    private var restaurantInfo : some View {
        VStack(alignment: .leading, spacing: 8){
            //open /close
            HStack{
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

            }
            
            //Hotel name
            Text(restaurant.name)
                .foregroundStyle(.mainbw)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack{
                VStack(alignment: .leading){
                    Text(restaurant.type)
                        .foregroundStyle(.mainbw)
                    Text("\(restaurant.city) | 2 Km")
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
                Text(restaurant.address)
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
                Text("\(restaurant.openingTime.formattedTime2()) - \(restaurant.closingTime.formattedTime2())")
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
        .padding(.bottom, 150)
    }
}

extension Date {
    func formattedTime2() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
}
