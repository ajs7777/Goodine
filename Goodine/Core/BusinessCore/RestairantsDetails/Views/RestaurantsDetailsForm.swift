//
//  RestaurantsDetailsForm.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/02/25.
//

import SwiftUI
import PhotosUI

struct RestaurantsDetailsForm: View {
    
//    @EnvironmentObject var restaurantVM : RestaurantsDetailsViewModel
    @EnvironmentObject var businessAuthMV : BusinessAuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var restaurant = Restaurant(id: "", ownerName: "", name: "", type: "", city: "", state: "", address: "", zipcode: "", averageCost: "", openingTime: Date(), closingTime: Date(), imageUrl: "")
    @State private var image: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView{
                    TextField("Business Name", text: $restaurant.name)
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 3)
                                .stroke(.mainbw, lineWidth: 1)
                        )
                    
                    TextField("Indian, Chienese", text: $restaurant.type)
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 3)
                                .stroke(.mainbw, lineWidth: 1)
                        )
                    
                    TextField("Address", text: $restaurant.address)
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 3)
                                .stroke(.mainbw, lineWidth: 1)
                        )
                    
                    HStack{
                        TextField("State", text: $restaurant.state)
                            .padding(.leading)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 3)
                                    .stroke(.mainbw, lineWidth: 1)
                            )
                        
                        TextField("City", text: $restaurant.city)
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
                        TextField("Zipcode", text: $restaurant.zipcode)
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
                        TextField("₹", text: $restaurant.averageCost)
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
                        DatePicker("From", selection: $restaurant.openingTime, displayedComponents: .hourAndMinute)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.orange)
                            .tint(.orange)
                        
                        DatePicker("To", selection: $restaurant.closingTime, displayedComponents: .hourAndMinute)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.orange)
                            .tint(.orange)
                        
                    }
                    
                    Divider()
                        .padding(.top)
                    
                    
                }
                .padding(.horizontal)
                .navigationTitle(Text("Hotel Details"))
                
                Spacer()
                
                Button{
                    Task {
                        do {
                            try await businessAuthMV.saveRestaurantDetails(restaurant, image: image)
                        } catch {
                            print("Saving failed: \(error.localizedDescription)")
                        }
                    }
                }label: {
                    Text("Save Restaurant")
                        .goodineButtonStyle(.mainbw)
                }
                
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
            
            .onTapGesture { self.hideKeyboard()}
        }
//        .onAppear {
//            Task{
//                await restaurantVM.fetchRestaurant()
//            }
//        }
        
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}

#Preview {
    RestaurantsDetailsForm()
    
}
