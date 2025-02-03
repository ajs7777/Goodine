//
//  ContentView.swift
//  Goodine
//
//  Created by Abhijit Saha on 20/01/25.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel : AuthViewModel
    
    var body: some View {
        Group{
            if viewModel.userSession != nil {
                MainTabView()
                    } else {
                        LoginWithNumberView()
                    }
        }
    }
}

#Preview {
    ContentView()
}
