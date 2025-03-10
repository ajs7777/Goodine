//
//  FoodRowView.swift
//  Goodine
//
//  Created by Abhijit Saha on 19/02/25.
//

import SwiftUI
import Kingfisher

struct FoodRowView: View {
    let menuItem: MenuItem
    var onDelete: () -> Void
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    
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
                                   VegNonVegIcon(size: 15, color: menuItem.veg ? .green : .red)
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
                                   VegNonVegIcon(size: 15, color: menuItem.veg ? .green : .red)
                                       .padding(8)
                               }
                       }
                
            
            VStack(alignment: .leading){
                Text(menuItem.foodname)
                    .fontWeight(.bold)
                Text(menuItem.foodDescription ?? "Food Description")
                    .font(.caption)
                    .foregroundStyle(.mainbw.opacity(0.5))
                
                let restaurant = businessAuthVM.restaurant
                
                Text("\(restaurant?.currencySymbol ?? "")\(menuItem.foodPrice)")
                    .foregroundStyle(.mainbw.opacity(0.5))
            }
            
            Spacer()
            
            VStack{
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.red)
                }
            }
        }
        
    }
}



