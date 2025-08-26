//
//  RestaurantsDetailsForm.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/02/25.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct RestaurantsDetailsForm: View {
    
    @ObservedObject var businessAuthVM : BusinessAuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedImages: [UIImage] = []
    @State private var isImagePickerPresented = false
    @State private var selectedCurrency: String = "INR"
    @State private var searchQuery: String = ""
    
    @StateObject private var restaurantLocationManager = RestaurantLocationManager()
    private let firestoreService = FirestoreService()
    
    var onLocationAllowed: () -> Void
    
    @State private var showAlert = false
    
    let currencySymbols: [String: String] = ["USD": "$", "EUR": "€", "INR": "₹", "GBP": "£", "JPY": "¥", "AUD": "A$", "CAD": "C$", "CNY": "¥", "SGD": "S$", "AED": "د.إ"]
    let currencies = ["USD", "EUR", "INR", "GBP", "JPY", "AUD", "CAD", "CNY", "SGD", "AED"]
    
    @State private var selectedFeatures: [String] = ["Reservation Available", "Dine in Available"]

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView{
                    TextField("Business Name", text: Binding(
                        get: { businessAuthVM.restaurant?.name ?? "" },
                        set: { businessAuthVM.restaurant?.name = $0 }
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
                        get: { businessAuthVM.restaurant?.type ?? "" },
                        set: { businessAuthVM.restaurant?.type = $0 }
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
                        get: { businessAuthVM.restaurant?.address ?? "" },
                        set: { businessAuthVM.restaurant?.address = $0 }
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
                            get: { businessAuthVM.restaurant?.state ?? "" },
                            set: { businessAuthVM.restaurant?.state = $0 }
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
                            get: { businessAuthVM.restaurant?.city ?? "" },
                            set: { businessAuthVM.restaurant?.city = $0 }
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
                            get: { businessAuthVM.restaurant?.zipcode ?? "" },
                            set: { businessAuthVM.restaurant?.zipcode = $0 }
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
                            let status = restaurantLocationManager.authorizationStatus
                            switch status {
                            case .notDetermined:
                                restaurantLocationManager.requestPermission()
                            case .authorizedWhenInUse, .authorizedAlways:
                                restaurantLocationManager.requestLocation()
                            case .denied, .restricted:
                                showAlert = true
                            default:
                                break
                            }
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
                        TextField("Upi Id", text: Binding(
                            get: { businessAuthVM.restaurant?.upiID ?? "" },
                            set: { businessAuthVM.restaurant?.upiID = $0 }
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
                                Text("Done")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            .foregroundStyle(.mainInvert)
                            .padding(15)
                            .frame(width: 180)
                            .background(.mainbw)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    HStack{
                        Text("Average Cost for two")
                            .font(.headline)
                        TextField("", text: Binding(
                            get: { businessAuthVM.restaurant?.averageCost ?? "" },
                            set: { businessAuthVM.restaurant?.averageCost = $0 }
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
                        Menu {
                            TextField("Search", text: $searchQuery)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            ForEach(currencies.filter { searchQuery.isEmpty || $0.contains(searchQuery.uppercased()) }, id: \.self) { currency in
                                Button(currency) {
                                    selectedCurrency = currency
                                    let symbol = currencySymbols[currency] ?? currency
                                    businessAuthVM.restaurant?.currency = currency
                                    businessAuthVM.restaurant?.currencySymbol = symbol
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(businessAuthVM.restaurant?.currencySymbol ?? getCurrencySymbol(for: selectedCurrency)) \(selectedCurrency.isEmpty ? "Select Currency" : selectedCurrency)")
                                Image(systemName: "chevron.down")
                            }
                            .foregroundStyle(.mainbw)
                            .padding(9)
                            .background(RoundedRectangle(cornerRadius: 7).stroke(.mainbw, lineWidth: 1))
                        }
                        .onAppear {
                            if let savedCurrency = businessAuthVM.restaurant?.currency {
                                selectedCurrency = savedCurrency
                            }
                        }

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
                            get: { businessAuthVM.restaurant?.openingTime ?? Date() },
                            set: { businessAuthVM.restaurant?.openingTime = $0 }
                        ), displayedComponents: .hourAndMinute)
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.orange)
                        .tint(.orange)
                        
                        DatePicker("To", selection:  Binding(
                            get: { businessAuthVM.restaurant?.closingTime ?? Date() },
                            set: { businessAuthVM.restaurant?.closingTime = $0 }
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
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(.mainbw)
                                    .fontWeight(.semibold)
                                    .background(.mainbw.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            if let imageUrls = businessAuthVM.restaurant?.imageUrls {
                                ForEach(imageUrls, id: \.self) { imageUrl in
                                    KFImage(URL(string: imageUrl)) // Using Kingfisher
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(alignment: .topTrailing) {
                                            Button(action: {
                                                Task {
                                                    await businessAuthVM.deleteImage(imageUrl)
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white.opacity(0.7))
                                                    .clipShape(Circle())
                                                    .padding(2)
                                            }
                                        }
                                    
                                }
                            } else {
                                ProgressView()
                            }
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(alignment: .topTrailing) {
                                        Button(action: {
                                            deleteImage(image: image)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white.opacity(0.7))
                                                .clipShape(Circle())
                                                .padding(2)
                                        }
                                    }
                            }
                        }
                    }
                    
                    // Custom feature input
                    FeatureSelectionView(selectedFeatures: $selectedFeatures)
                        .onAppear {
                            if let savedFeatures = businessAuthVM.restaurant?.features {
                                selectedFeatures = savedFeatures
                            } else {
                                selectedFeatures = ["Reservation Available", "Dine in Available"]
                            }
                        }
                    
                    .padding(.bottom, 50)

                    
                }
                .scrollIndicators(.hidden)
                .padding(.horizontal)
                .navigationTitle(Text("Hotel Details"))
                
                Spacer()
                
                Button{
                    Task {
                        do {
                            businessAuthVM.restaurant?.features = selectedFeatures
                            if let restaurant = businessAuthVM.restaurant {
                                try await businessAuthVM.saveRestaurantDetails(restaurant, images: selectedImages)
                                selectedImages.removeAll()
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
            .alert("Location Access Denied", isPresented: $showAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable location access in Settings to use this feature.")
            }
            .onReceive(restaurantLocationManager.$restaurantLocation) { location in
                if let location = location {
                    let lat = location.coordinate.latitude
                    let lon = location.coordinate.longitude
                    
                    firestoreService.saveRestaurantLocation(latitude: lat, longitude: lon) { error in
                        if error == nil {
                            UserDefaults.standard.set(true, forKey: "locationPermissionGranted")
                            onLocationAllowed()
                        } else {
                            print("Failed to save location: \(error!.localizedDescription)")
                        }
                    }
                }
            }
        }
        
    }
    
    func deleteImage(image: UIImage) {
        if let index = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: index)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func getCurrencySymbol(for currencyCode: String) -> String {
        let locale = NSLocale(localeIdentifier: currencyCode)
        return locale.displayName(forKey: .currencySymbol, value: currencyCode) ?? currencyCode
    }

    
}


