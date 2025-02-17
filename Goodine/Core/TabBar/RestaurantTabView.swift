//
//  RestaurantTabView.swift
//  Goodine
//
//  Created by Abhijit Saha on 04/02/25.
//

import SwiftUI

struct RestaurantTabView: View {
    
    var body: some View {
        TabView{
            RestaurantProfile()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Profile")
                }
            
            TableView()
                .tabItem {
                    Image(systemName: "table.furniture.fill")
                        .imageScale(.large)
                    Text("Table")
                }
            
            OrdersView()
                .tabItem {
                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    Text("History")
                }
        }
        .tint(.mainbw)
    }
}

#Preview {
    RestaurantTabView()
}
