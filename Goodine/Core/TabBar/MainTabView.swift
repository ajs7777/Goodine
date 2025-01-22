//
//  MainTabView.swift
//  Goodine
//
//  Created by Abhijit Saha on 21/01/25.
//

import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab = 4
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Home view")
                .tabItem {
                    VStack{
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        Text("Home")
                    }
                }
                .tag(0)
                //.onAppear { selectedTab = 0 }
            
            Text("Restaurants")
                .tabItem {
                    VStack{
                        Image(systemName: selectedTab == 1 ? "fork.knife.circle.fill" : "fork.knife.circle")
                            .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                        
                        Text("Dine IN")
                    }
                }
                .tag(1)
               // .onAppear { selectedTab = 1 }
            
            Text("Book a Table")
                .tabItem {
                    VStack{
                        Image(systemName: "table.furniture.fill")
                    }
                }
                .tag(2)
               // .onAppear { selectedTab = 2 }
            
            Text("Favourites")
                .tabItem {
                    VStack{
                        Image(systemName:  selectedTab == 3 ? "heart.fill" :  "heart")
                            .environment(\.symbolVariants, selectedTab == 3 ? .fill : .none)
                        
                        Text("Favourites")
                    }
                }
                .tag(3)
                //.onAppear { selectedTab = 3 }
            
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
        }
        .tint(.black.opacity(0.6))
        
    }
}

#Preview {
    MainTabView()
}
