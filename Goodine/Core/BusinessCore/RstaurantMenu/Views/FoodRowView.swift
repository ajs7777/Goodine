//
//  FoodRowView.swift
//  Goodine
//
//  Created by Abhijit Saha on 19/02/25.
//

import SwiftUI

struct FoodRowView: View {
    
    @State var count: Int = 0
    let menuItem : [MenuItem]
    
    var body: some View {
        HStack{
            Image(menuItem[0].foodImage ?? "fork.knife")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .bottomLeading) {
                    VegNonVegIcon(size: 15, color: .red)
                        .padding(8)
                }
            
            VStack(alignment: .leading){
                Text(menuItem[0].foodname)
                    .fontWeight(.bold)
                Text(menuItem[0].foodDescription ?? "Food Description")
                    .font(.caption)
                    .foregroundStyle(.mainbw.opacity(0.5))
                
                Text("₹\(menuItem[0].foodPrice)")
                    .foregroundStyle(.mainbw.opacity(0.5))
            }
            
            Spacer()
            
            VStack{
                Button{
                    
                }label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
            
//            HStack(spacing: 8) {
//                        Button(action: {
//                            if count > 0 { count -= 1 } // Prevent going below 0
//                        }) {
//                            Image(systemName: "minus")
//                                .foregroundStyle(.mainbw)
//                                .font(.system(size: 15, weight: .heavy))
//                                .frame(width: 20, height: 15)
//                                .background(Color(.systemGray6))
//                                .clipShape(Circle())
//                        }
//                        .disabled(count == 0) // Disable button at 0
//                        .opacity(count == 0 ? 0.5 : 1.0) // Reduce opacity when disabled
//
//                        Text("\(count)")
//                            .font(.system(size: 15, weight: .heavy))
//                            .frame(width: 20, alignment: .center)
//
//                        Button(action: { count += 1 }) {
//                            Image(systemName: "plus")
//                                .foregroundStyle(.mainbw)
//                                .font(.system(size: 15, weight: .heavy))
//                                .frame(width: 20, height: 15)
//                                .background(Color(.systemGray6))
//                                .clipShape(Circle())
//                        }
//                    }
//                    .padding(8)
//                    .background(Color(.systemGray6))
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .shadow(radius: 1)
        }
    }
}

#Preview {
    FoodRowView( menuItem: [MenuItem(id: "1", foodname: "Mutton Biriyani", foodDescription: "Best Biriyani", foodPrice: 599, foodQuantity: 1, foodImage: "biriyani")])
}
