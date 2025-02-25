//
//  RestaurantMenu.swift
//  Goodine
//
//  Created by Abhijit Saha on 19/02/25.
//

import SwiftUI

struct RestaurantMenu: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = RestaurantMenuViewModel()
    @State private var showAddItemSheet = false
    @State private var editingItem: MenuItem?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(viewModel.items) { item in
                    FoodRowView(menuItem: item, onDelete: {
                        viewModel.deleteItem(item)
                    })
                    .onTapGesture {
                        editingItem = item
                        showAddItemSheet = true
                    }
                }
                .navigationTitle("Menu")
            }
            .scrollIndicators(.hidden)
            .padding(.top, 20)
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingItem = nil
                        showAddItemSheet = true
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
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.mainbw)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddItemSheet) {
                    if let item = editingItem {
                        // 🔥 Editing an existing item
                        AddItemView(menuItem: item) { updatedItem, image in
                            if let index = viewModel.items.firstIndex(where: { $0.id == updatedItem.id }) {
                                viewModel.items[index] = updatedItem // 🔥 Update local list
                            }
                            viewModel.saveItemToFirestore(updatedItem, image: image)
                        }
                    } else {
                        // 🔥 Adding a new item
                        AddItemView { newItem, image in
                            viewModel.items.append(newItem) // 🔥 Add to list
                            viewModel.saveItemToFirestore(newItem, image: image)
                        }
                    }
                }
        .onAppear {
            viewModel.fetchMenuItems()
        }
        
    }
}

#Preview {
    RestaurantMenu()
}
