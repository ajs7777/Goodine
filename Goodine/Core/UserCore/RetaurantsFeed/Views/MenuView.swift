//
//  RestaurantMenu.swift
//  Goodine
//
//  Created by Abhijit Saha on 25/05/25.
//


import SwiftUI
import Kingfisher

struct MenuView: View {
    
    @Environment(\.dismiss) var dismiss
    let restaurantID: String
    @StateObject private var viewModel : MenuViewModel
    @StateObject private var businessAuthVM : RestroDetailsViewModel
    
    
    @State private var showAddItemSheet = false
    @State private var editingItem: MenuItem?
    
    init(restaurantID: String) {
        self.restaurantID = restaurantID
        _viewModel = StateObject(wrappedValue: MenuViewModel(restaurantID: restaurantID))
        _businessAuthVM = StateObject(wrappedValue: RestroDetailsViewModel(restaurantID: restaurantID))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(viewModel.items) { item in
                    RestaurantFoodRowView(menuItem: item, restaurant: businessAuthVM.restaurant)
                    
                }
                .navigationTitle("Menu")
            }
            .scrollIndicators(.hidden)
            .padding(.top, 20)
            .padding(.horizontal)
            .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                    Button{
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.mainbw)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchMenuItems()
        }
        
    }
}


struct RestaurantFoodRowView: View {
    let menuItem: MenuItem
    let restaurant : Restaurant?
    
    var body: some View {
        HStack(spacing: 10){
            if let imageUrl = menuItem.foodImage, let url = URL(string: imageUrl) {
                           KFImage(url)
                               .resizable()
                               .placeholder {
                                           ProgressView()
                                       }
                               .scaledToFill()
                               .frame(width: 80, height: 80)
                               .clipShape(RoundedRectangle(cornerRadius: 12))
                               .overlay(alignment: .bottomLeading) {
                                   VegNonVegIcon(size: 15, color: menuItem.isVeg ? .green : .red)
                                       .padding(8)
                               }
                               
                       } else {
                           Image(systemName: "photo")
                               .resizable()
                               .scaledToFit()
                               .foregroundColor(.mainbw.opacity(0.5))
                               .frame(width: 30, height: 30)
                               .padding(25)
                               .background(.mainbw.opacity(0.2))
                               .clipShape(RoundedRectangle(cornerRadius: 12))
                               .overlay(alignment: .bottomLeading) {
                                   VegNonVegIcon(size: 15, color: menuItem.isVeg ? .green : .red)
                                       .padding(8)
                               }
                       }
                
            
            VStack(alignment: .leading){
                Text(menuItem.foodname)
                    .fontWeight(.bold)
                Text(menuItem.foodDescription ?? "Food Description")
                    .font(.caption)
                    .foregroundStyle(.mainbw.opacity(0.5))
                
                
                Text("\(restaurant?.currencySymbol ?? "")\(menuItem.foodPrice)")
                    .foregroundStyle(.mainbw.opacity(0.5))
            }
            
            Spacer()
            
        }
        
    }
}
