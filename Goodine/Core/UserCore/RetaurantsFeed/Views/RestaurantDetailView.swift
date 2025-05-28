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
    let distanceInKm: Double?
    
    var isOpen: Bool {
        let openingTime = restaurant.openingTime
        let closingTime = restaurant.closingTime
        
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
        let openingTime = restaurant.openingTime
        let closingTime = restaurant.closingTime
        
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
        
        ZStack{
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
            menuIcon
        }
        .navigationBarBackButtonHidden(true)
        .enableSwipeBackGesture()
        .onAppear {
            Task{
                await businessAuthVM.fetchAllRestaurants()
            }
            FavoritesManager.fetchFavoriteStatus(for: restaurant.id) { status in
                    isFavorite = status
                }
        }
        // book a table button works as sheet
        .sheet(isPresented: $showBookingSheet, content: {
            BookATableView(restaurantID: restaurant.id)
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
    RestaurantDetailView( restaurant: Restaurant(id: "", ownerName: "", name: "Limelight - Orchid Heritage", type: "Indian, Chinese", city: "Agartala", state: "", address: "VN lane 1 - Agartala, Tripura 799009", zipcode: "", averageCost: "", openingTime: Date(), closingTime: Date(), imageUrls: [], currency: "INR", currencySymbol: "₹"), distanceInKm: 0.00)
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
                    FavoritesManager.toggleFavorite(for: restaurant.id) { newStatus in
                                isFavorite = newStatus
                            }
                }
            
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
                    Text("\(restaurant.city) | \(String(format: "%.1f Km", distanceInKm ?? 0.0))")
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8.0){
                    HStack(alignment: .center, spacing: 3.0) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.footnote)
                        Text("No Ratings")
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
        VStack(alignment: .leading, spacing: 20.0) {
            Text("Features")
                .foregroundStyle(.mainbw)
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(restaurant.features, id: \.self) { feature in
                    Text(feature)
                        .foregroundStyle(.mainbw)
                        .fontWeight(.medium)
                        .padding(10)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.bottom, 150)

    }
    
    private var menuIcon : some View {
        VStack(){
            Spacer()
            HStack{
                Spacer()
                NavigationLink {
                    MenuView(restaurantID: restaurant.id)
                        .navigationBarBackButtonHidden()
                } label: {
                    HStack {
                        Image(.businessicon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                        
                        Text("Menu")
                        
                    }
                    .foregroundStyle(.mainInvert)
                    .padding()
                    .background(.mainbw)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 7)
                    .padding()
                    .padding(.bottom, 70)
                }
            }
        }
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
