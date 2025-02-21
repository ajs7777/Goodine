//
//  RestaurantMenu.swift
//  Goodine
//
//  Created by Abhijit Saha on 19/02/25.
//

import SwiftUI

struct RestaurantMenu: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack{
            ScrollView {
                ForEach(0..<10) { item in
                    FoodRowView()
                }
                .navigationTitle("Menu")
            }
            .padding(.top, 20)
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        HStack {
                            Text("Add Item")
                            Image(systemName: "plus")
                        }
                        .foregroundStyle(.mainbw)
                        .fontWeight(.bold)
                        .padding(.trailing)
                        .padding(.top)
                    }

                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button{
                        dismiss()
                    }label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.mainbw)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

#Preview {
    RestaurantMenu()
}
