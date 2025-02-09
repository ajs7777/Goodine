//
//  ContentView.swift
//  Goodine
//
//  Created by Abhijit Saha on 20/01/25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var businessAuthMV : BusinessAuthViewModel
    
    var body: some View {
        if businessAuthMV.businessUser != nil {
            RestaurantTabView()
        } else {
            LoginWithNumberView()
        }
    }
}

#Preview {
    ContentView()
        
}



