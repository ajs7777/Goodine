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
                
                Text("₹\(menuItem.foodPrice)")
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

//#Preview {
//    FoodRowView( menuItem: [MenuItem(id: "1", foodname: "Mutton Biriyani", foodDescription: "Best Biriyani", foodPrice: 599, foodQuantity: 1, foodImage: "fork.knife")])
//}


//HStack(spacing: 8) {
//            Button(action: {
//                if count > 0 { count -= 1 } // Prevent going below 0
//            }) {
//                Image(systemName: "minus")
//                    .foregroundStyle(.mainbw)
//                    .font(.system(size: 15, weight: .heavy))
//                    .frame(width: 20, height: 15)
//                    .background(Color(.systemGray6))
//                    .clipShape(Circle())
//            }
//            .disabled(count == 0) // Disable button at 0
//            .opacity(count == 0 ? 0.5 : 1.0) // Reduce opacity when disabled
//
//            Text("\(count)")
//                .font(.system(size: 15, weight: .heavy))
//                .frame(width: 20, alignment: .center)
//
//            Button(action: { count += 1 }) {
//                Image(systemName: "plus")
//                    .foregroundStyle(.mainbw)
//                    .font(.system(size: 15, weight: .heavy))
//                    .frame(width: 20, height: 15)
//                    .background(Color(.systemGray6))
//                    .clipShape(Circle())
//            }
//        }
//        .padding(8)
//        .background(Color(.systemGray6))
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .shadow(radius: 1)
