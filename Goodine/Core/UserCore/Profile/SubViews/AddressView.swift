//
//  AddressView.swift
//  Goodine
//
//  Created by Abhijit Saha on 03/06/25.
//

import SwiftUI

struct AddressView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM : AuthViewModel
    @EnvironmentObject var locationVM : LocationViewModel
    @StateObject private var userLocationVM = UserLocationManager()
    private let userLocationService = UserLocationService()
    
    @State private var showAlert = false
    
    var onLocationAllowed: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(){
                VStack(alignment: .leading, spacing: 10){
                    if let user = authVM.userdata {
                        HStack {
                            Image(systemName: "house")
                                .fontWeight(.semibold)
                            Text(user.fullName)
                                .fontWeight(.semibold)
                            
                        }
                        
                        Text(locationVM.formattedAddress)
                        
                        Text(user.phoneNumber)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(.mainbw.opacity(0.1))
                .cornerRadius(10)
                
                Button {
                    let status = userLocationVM.authorizationStatus
                    switch status {
                    case .notDetermined:
                        userLocationVM.requestPermission()
                    case .authorizedWhenInUse, .authorizedAlways:
                        userLocationVM.requestLocation()
                    case .denied, .restricted:
                        showAlert = true
                    default:
                        break
                    }
                } label: {
                    HStack{
                        Image(systemName: "location.fill")
                            .fontWeight(.semibold)
                        Text("Update Address")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.orange)
                .cornerRadius(10)
                .padding(.top)
                .padding(.horizontal)
                
                
                Spacer()
            }
            
            .foregroundStyle(.mainbw)
            .padding()
            .padding(.top)
            .navigationTitle("Address")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .bold()
                        .foregroundStyle(.mainbw)
                }
            }
        }
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
        .onReceive(userLocationVM.$userLocation) { location in
            if let location = location {
                let lat = location.coordinate.latitude
                let lon = location.coordinate.longitude
                
                userLocationService.saveUserLocation(latitude: lat, longitude: lon) { error in
                    if error == nil {
                        UserDefaults.standard.set(true, forKey: "locationPermissionAllowed")
                        onLocationAllowed()
                    } else {
                        print("Failed to save location: \(error!.localizedDescription)")
                    }
                }
            }
        }
    }
}

#Preview {
    AddressView(onLocationAllowed: {})
}
