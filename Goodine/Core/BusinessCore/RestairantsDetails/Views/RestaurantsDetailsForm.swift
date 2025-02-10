//
//  RestaurantsDetailsForm.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/02/25.
//

import SwiftUI
import PhotosUI

struct RestaurantsDetailsForm: View {
    
    @ObservedObject var businessAuthMV : BusinessAuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedImages: [UIImage] = []
    @State private var isImagePickerPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView{
                    TextField("Business Name", text: Binding(
                        get: { businessAuthMV.restaurant?.name ?? "" },
                        set: { businessAuthMV.restaurant?.name = $0 }
                    ))
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 3)
                            .stroke(.mainbw, lineWidth: 1)
                    )
                    
                    TextField("Indian, Chienese", text: Binding(
                        get: { businessAuthMV.restaurant?.type ?? "" },
                        set: { businessAuthMV.restaurant?.type = $0 }
                    ))
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 3)
                            .stroke(.mainbw, lineWidth: 1)
                    )
                    
                    TextField("Address", text: Binding(
                        get: { businessAuthMV.restaurant?.address ?? "" },
                        set: { businessAuthMV.restaurant?.address = $0 }
                    ))
                    .padding(.leading)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 3)
                            .stroke(.mainbw, lineWidth: 1)
                    )
                    
                    HStack{
                        TextField("State", text: Binding(
                            get: { businessAuthMV.restaurant?.state ?? "" },
                            set: { businessAuthMV.restaurant?.state = $0 }
                        ))
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 3)
                                .stroke(.mainbw, lineWidth: 1)
                        )
                        
                        TextField("City", text: Binding(
                            get: { businessAuthMV.restaurant?.city ?? "" },
                            set: { businessAuthMV.restaurant?.city = $0 }
                        ))
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 3)
                                .stroke(.mainbw, lineWidth: 1)
                        )
                        
                        
                    }
                    
                    HStack{
                        TextField("Zipcode", text: Binding(
                            get: { businessAuthMV.restaurant?.zipcode ?? "" },
                            set: { businessAuthMV.restaurant?.zipcode = $0 }
                        ))
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 3)
                                .stroke(.mainbw, lineWidth: 1)
                        )
                        
                        Button{
                            
                        } label: {
                            HStack{
                                Image(systemName: "dot.scope")
                                    .fontWeight(.black)
                                Text("Use My Location")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(.white)
                            .padding(13)
                            .frame(width: 180)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    HStack{
                        Text("Average Cost for two")
                            .font(.headline)
                        TextField("₹", text: Binding(
                            get: { businessAuthMV.restaurant?.averageCost ?? "" },
                            set: { businessAuthMV.restaurant?.averageCost = $0 }
                        ))
                        .keyboardType(.numberPad)
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 3)
                                .stroke(.mainbw, lineWidth: 1)
                        )
                        
                    }
                    .padding(.vertical, 10)
                    
                    VStack {
                        Text("Opening Hours:")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.vertical, 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    VStack{
                        DatePicker("From", selection: Binding(
                            get: { businessAuthMV.restaurant?.openingTime ?? Date() },
                            set: { businessAuthMV.restaurant?.openingTime = $0 }
                        ), displayedComponents: .hourAndMinute)
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.orange)
                        .tint(.orange)
                        
                        DatePicker("To", selection:  Binding(
                            get: { businessAuthMV.restaurant?.closingTime ?? Date() },
                            set: { businessAuthMV.restaurant?.closingTime = $0 }
                        ), displayedComponents: .hourAndMinute)
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.orange)
                        .tint(.orange)
                        
                    }
                    
                    Divider()
                        .padding(.top)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            Button{
                                isImagePickerPresented.toggle()
                            }label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .padding(20)
                            }
                            
                            if let imageUrls = businessAuthMV.restaurant?.imageUrls {
                                ForEach(imageUrls, id: \.self) { imageUrl in
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        if let image = phase.image {
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        } else {
                                            ProgressView()
                                                .frame(width: 100, height: 100)
                                        }
                                    }
                                    .overlay(alignment: .topTrailing) {
                                        Button(action: {
                                            Task {
                                                await businessAuthMV.deleteImage(imageUrl)
                                            }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white.opacity(0.7))
                                                .clipShape(Circle())
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                    .padding(.bottom, 50)
                    
                }
                .padding(.horizontal)
                .navigationTitle(Text("Hotel Details"))
                
                Spacer()
                
                Button{
                    Task {
                        do {
                            if let restaurant = businessAuthMV.restaurant {
                                try await businessAuthMV.saveRestaurantDetails(restaurant, images: selectedImages)
                                dismiss()
                                
                            }
                        } catch {
                            print("Error saving details: \(error.localizedDescription)")
                        }
                    }
                }label: {
                    Text("Save & Continue")
                        .goodineButtonStyle(.mainbw)
                }
                
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
            .sheet(isPresented: $isImagePickerPresented) {
                RestaurantImagePicker(images: $selectedImages)
            }
            .onTapGesture { self.hideKeyboard()}
        }
        
        
    }
    
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

#Preview {
    RestaurantsDetailsForm(businessAuthMV: BusinessAuthViewModel())
    
}


