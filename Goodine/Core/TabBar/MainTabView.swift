//
//  MainTabView.swift
//  Goodine
//
//  Created by Abhijit Saha on 21/01/25.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RestaurantsFeedView()
                .tabItem {
                    VStack{
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                        Text("Home")
                    }
                }
                .tag(0)
                //.onAppear { selectedTab = 0 }
                .toolbarBackground(.mainInvert, for: .tabBar)
                
            
            Text("Restaurants")
                .tabItem {
                    VStack{
                        Image(systemName: selectedTab == 1 ? "fork.knife.circle.fill" : "fork.knife.circle")
                            .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                        
                        Text("Dine In")
                    }
                }
                .tag(1)
               // .onAppear { selectedTab = 1 }
                .toolbarBackground(.mainInvert, for: .tabBar)
            
            Text("Book a Table")
                .tabItem {
                    VStack{
                        Image(systemName: "table.furniture.fill")
                    }
                }
                .tag(2)
               // .onAppear { selectedTab = 2 }
                .toolbarBackground(.mainInvert, for: .tabBar)
            
            FavouriteRestaurantsView()
                .tabItem {
                    VStack{
                        Image(systemName:  selectedTab == 3 ? "heart.fill" :  "heart")
                            .environment(\.symbolVariants, selectedTab == 3 ? .fill : .none)
                        
                        Text("Favourites")
                    }
                }
                .tag(3)
                //.onAppear { selectedTab = 3 }
                .toolbarBackground(.mainInvert, for: .tabBar)
            
            ProfileView()
                .tabItem {
                    VStack{
                        Image(systemName: selectedTab == 4 ? "person.circle.fill" : "person.circle")
                            .environment(\.symbolVariants, selectedTab == 4 ? .fill : .none)
                        
                        Text("Profile")
                    }
                }
            
                .tag(4)
               // .onAppear { selectedTab = 4 }
                .toolbarBackground(.mainInvert, for: .tabBar)
        }
        
        .tint(.mainbw)
        
        
    }
}

#Preview {
    MainTabView()
}
