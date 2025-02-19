//
//  FoodMenuView.swift
//  Goodine
//
//  Created by Abhijit Saha on 15/02/25.
//

import SwiftUI

struct FoodMenuView: View {
    let tableNumber: Int = 1
    @State private var selectedItems: [String] = []
    
    let menuItems = ["Pizza", "Burger", "Pasta", "Salad", "Soda"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    Text("Table \(tableNumber)")
                        .font(.title)
                        .bold()
                    
                    ForEach(0..<10) { _ in
                        FoodRowView()
                    }
                    
//                    ForEach(menuItems, id: \.self) { item in
//                        HStack {
//                            Text(item)
//                            Spacer()
//                            if selectedItems.contains(item) {
//                                Image(systemName: "checkmark.circle.fill")
//                                    .foregroundColor(.green)
//                            }
//                        }
//                        .onTapGesture {
//                            if selectedItems.contains(item) {
//                                selectedItems.removeAll { $0 == item }
//                            } else {
//                                selectedItems.append(item)
//                            }
//                        }
//                    }
                    
                    Button("Place Order") {
                        print("Order placed: \(selectedItems) for Table \(tableNumber)")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
                }
                .padding()
                .navigationTitle("Order Food")
            }
        }
    }
}

#Preview {
    FoodMenuView()
}
