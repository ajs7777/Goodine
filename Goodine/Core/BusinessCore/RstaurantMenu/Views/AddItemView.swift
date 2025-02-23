//
//  AddItemView.swift
//  Goodine
//
//  Created by Abhijit Saha on 21/02/25.
//

import SwiftUI
import Kingfisher

struct AddItemView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var foodname = ""
    @State private var foodDescription = ""
    @State private var foodPrice = ""
    @State private var isVeg = false
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
        
    var menuItem: MenuItem?
    var onSave: (MenuItem, UIImage?) -> Void
    
    init(menuItem: MenuItem? = nil, onSave: @escaping (MenuItem, UIImage?) -> Void) {
        
        _foodname = State(initialValue: menuItem?.foodname ?? "")
        _foodDescription = State(initialValue: menuItem?.foodDescription ?? "")
        _foodPrice = State(initialValue: menuItem?.foodPrice != nil ? "\(menuItem!.foodPrice)" : "")
        _isVeg = State(initialValue: menuItem?.veg ?? false)
        
        self.menuItem = menuItem
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if let existingImageUrl = menuItem?.foodImage, let url = URL(string: existingImageUrl) {
                    KFImage(url)
                        .resizable()
                        .placeholder {
                            ProgressView()
                        }
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                }
                TextField("Food Name", text: $foodname)
                    .fontWeight(.semibold)
                TextField("Description", text: $foodDescription)
                    .fontWeight(.semibold)
                TextField("Price", text: $foodPrice)
                    .keyboardType(.numberPad)
                    .fontWeight(.semibold)
                Toggle("Veg", isOn: $isVeg)
                    .tint(.green)
                    .fontWeight(.semibold)
               
                
                Button("Upload Image") {
                    showImagePicker = true
                } .fontWeight(.semibold)
            }
            .navigationTitle(menuItem == nil ? "Add Item" : "Edit Item")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        if let price = Int(foodPrice) {
                            let updatedItem = MenuItem(
                                id: menuItem?.id ?? UUID().uuidString,  // 🔥 Keeps original ID if editing
                                foodname: foodname,
                                foodDescription: foodDescription,
                                foodPrice: price,
                                foodImage: menuItem?.foodImage, // 🔥 Keeps old image if not changed
                                veg: isVeg
                            )
                            onSave(updatedItem, selectedImage)
                            dismiss()
                        }
                    } .bold()

                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
        .presentationDetents(menuItem == nil ? [.fraction(0.65)] : [.fraction(0.75)])
        .onAppear { // 🔥 Update form fields when the view appears
                    if let menuItem = menuItem {
                        foodname = menuItem.foodname
                        foodDescription = menuItem.foodDescription ?? ""
                        foodPrice = "\(menuItem.foodPrice)"
                        isVeg = menuItem.veg
                    }
                }
        .sheet(isPresented: $showImagePicker) {
            FoodImagePicker(selectedImage: $selectedImage)
        }
        

    }
    
}

