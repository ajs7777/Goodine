//
//  ContentView.swift
//  Goodine
//
//  Created by Abhijit Saha on 20/01/25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    @EnvironmentObject var userAuthVM : AuthViewModel
    
    var body: some View {
        if userAuthVM.isLoading {
            ProgressView()
        } else if userAuthVM.userdata != nil {
            MainTabView()
        } else if businessAuthVM.restaurant != nil {
            RestaurantTabView()
        }
         else {
            LoginWithNumberView()
        }
    }
}

#Preview {
    ContentView()
        
}
