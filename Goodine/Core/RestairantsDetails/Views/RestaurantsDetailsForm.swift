//
//  RestaurantsDetailsForm.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/02/25.
//

import SwiftUI

struct RestaurantsDetailsForm: View {
    
    @EnvironmentObject var viewModel : AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State var restaurantName = ""
    @State var restaurantType = ""
    @State var restaurantAddress = ""
    @State var restaurantState = ""
    @State var restaurantCity = ""
    @State var restaurantZipCode = ""
    @State var restaurantAverageCost = ""
    @State var startTime = Date()
    @State var endTime = Date()
    @State private var selectedImages: [UIImage] = []
    @State private var showImagePicker = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView{
                    TextField("Business Name", text: $restaurantName)
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 3)
                                .stroke(.mainbw, lineWidth: 1)
                        )
                    
                    TextField("Indian, Chienese", text: $restaurantType)
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 3)
                                .stroke(.mainbw, lineWidth: 1)
                        )
                    
                    TextField("Address", text: $restaurantAddress)
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 3)
                                .stroke(.mainbw, lineWidth: 1)
                        )
                    
                    HStack{
                        TextField("State", text: $restaurantState)
                            .padding(.leading)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 3)
                                    .stroke(.mainbw, lineWidth: 1)
                            )
                        
                        TextField("City", text: $restaurantCity)
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
                        TextField("Zipcode", text: $restaurantZipCode)
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
                        TextField("₹", text: $restaurantAverageCost)
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
                        DatePicker("From", selection: $startTime, displayedComponents: .hourAndMinute)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.orange)
                            .tint(.orange)
                        
                        DatePicker("To", selection: $endTime, displayedComponents: .hourAndMinute)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.orange)
                            .tint(.orange)
                        
                    }
                    
                    Divider()
                        .padding(.top)
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Button(action: { showImagePicker.toggle() }) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                                    .padding(80)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    
                    
                    
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal)
                .navigationTitle(Text("Hotel Details"))
                
                Spacer()
                
                Button {
                    Task {
                        await saveRestaurant()
                    }
                    dismiss()
                } label: {
                    Text("Continue")
                        .goodineButtonStyle(.mainbw)
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
            .onTapGesture {
                self.hideKeyboard()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            RestaurantImagePicker(selectedImages: $selectedImages)
        }
    }
    
    private func saveRestaurant() async {
        let restaurant = Restaurant(
            restaurantName: restaurantName,
            restaurantType: restaurantType,
            restaurantAddress: restaurantAddress,
            restaurantState: restaurantState,
            restaurantCity: restaurantCity,
            restaurantZipCode: restaurantZipCode,
            restaurantAverageCost: restaurantAverageCost,
            startTime: startTime,
            endTime: endTime
        )
        
        do {
            try await viewModel.saveRestaurantDetails(restaurant: restaurant, images: selectedImages)

            print("Restaurant details saved successfully!")
        } catch {
            print("Error saving restaurant details: \(error.localizedDescription)")
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

#Preview {
    RestaurantsDetailsForm()
    
}
