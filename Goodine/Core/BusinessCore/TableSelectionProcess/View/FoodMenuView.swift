//
//  FoodMenuView.swift
//  Goodine
//
//  Created by Abhijit Saha on 15/02/25.
//

import SwiftUI
import Kingfisher

struct FoodMenuView: View {
    
    @StateObject var orderVM = OrdersViewModel()
    @ObservedObject var tableVM = TableViewModel()
    @ObservedObject var viewModel = RestaurantMenuViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedItems: [String: Int] = [:]
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                       ScrollView {
                           LazyVStack(alignment: .leading) {
                               ForEach(viewModel.items) { item in
                                   FoodMenuItemView(item: item, selectedItems: $selectedItems)
                               }
                           }
                           
                       }
                       Button("Place Order") {
                           orderVM.saveOrderToFirestore(reservationId: tableVM.reservations.first?.id ?? "", selectedItems: selectedItems, menuItems: viewModel.items)
                           dismiss()
                       }
                       .goodineButtonStyle(.mainbw)
                   }
                   .padding()
                   .navigationTitle("Order Food")
               }
       
    }
}

#Preview {
    FoodMenuView()
}

struct FoodMenuItemView: View {
    var item: MenuItem
    
    @Binding var selectedItems: [String: Int]
    @State private var quantity: Int = 0
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    
    var body: some View {
        HStack(spacing: 10) {
            if let imageUrl = item.foodImage, let url = URL(string: imageUrl) {
                KFImage(url)
                    .resizable()
                    .placeholder { ProgressView() }
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(alignment: .bottomLeading) {
                        VegNonVegIcon(size: 15, color: item.isVeg ? .green : .red)
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
                        VegNonVegIcon(size: 15, color: item.isVeg ? .green : .red)
                            .padding(8)
                    }
            }
            
            VStack(alignment: .leading) {
                Text(item.foodname)
                    .fontWeight(.bold)
                Text(item.foodDescription ?? "Food Description")
                    .font(.caption)
                    .foregroundStyle(.mainbw.opacity(0.5))
                let restaurant = businessAuthVM.restaurant
                
                Text("\(restaurant?.currencySymbol ?? "")\(item.foodPrice)")
                    .foregroundStyle(.mainbw.opacity(0.5))
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    if quantity > 0 {
                        quantity -= 1
                        selectedItems[item.id] = quantity
                        if quantity == 0 {
                            selectedItems.removeValue(forKey: item.id)
                        }
                    }
                }) {
                    Image(systemName: "minus")
                        .foregroundStyle(.mainbw)
                        .font(.system(size: 15, weight: .heavy))
                        .frame(width: 25, height: 25)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .disabled(quantity == 0)
                .opacity(quantity == 0 ? 0.5 : 1.0)

                Text("\(quantity)")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 25, alignment: .center)

                Button(action: {
                    quantity += 1
                    selectedItems[item.id] = quantity
                }) {
                    Image(systemName: "plus")
                        .foregroundStyle(.mainbw)
                        .font(.system(size: 15, weight: .heavy))
                        .frame(width: 25, height: 25)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 1)
        }
        .onAppear {
            quantity = selectedItems[item.id] ?? 0
        }
    }
}

