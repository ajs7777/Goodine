//
//  LocationManager.swift
//  Goodine
//
//  Created by Abhijit Saha on 05/05/25.
//


import SwiftUI
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseAuth

// MARK: - Location Manager

class UserLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
}

// MARK: - Data Model

struct UserLocationData: Codable {
    var latitude: Double
    var longitude: Double
    var cityName: String?
    var areaName: String?
}

// MARK: - Firestore Service

class UserLocationService {
    private let db = Firestore.firestore()
    
    func saveUserLocation(latitude: Double, longitude: Double, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "UserLocationService", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        let locationData = LocationData(latitude: latitude, longitude: longitude)
        
        do {
            try db.collection("users")
                .document(userId)
                .collection("userLocations")
                .document("locations") // Use a fixed ID like "main"
                .setData(from: locationData, merge: true, completion: completion)
        } catch {
            completion(error)
        }
    }
}


// MARK: - Main View

struct UserLocation: View {
    @StateObject private var userLocationManager = UserLocationManager()
    private let userLocationService = UserLocationService()
    
    var onLocationAllowed: () -> Void
    
    @State private var showAlert = false
    
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Image(.locationAccess)
                .resizable()
                .frame(width: 450, height: 450)
                .foregroundColor(.blue)
                .padding()
            
            Spacer()
            
                Text("Your Goodine, your billing app.")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.mainbw)
                
                Text("Get started with Goodine.")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.mainbw)
                    .padding(.bottom, 10)
                
                Text("Allow Goodine to access your location to get best and personalized options in dining, billing and more")
                    .font(.footnote)
                    .foregroundStyle(.mainbw.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
            Spacer()
                
                Button(action: {
                    let status = userLocationManager.authorizationStatus
                    switch status {
                    case .notDetermined:
                        userLocationManager.requestPermission()
                    case .authorizedWhenInUse, .authorizedAlways:
                        userLocationManager.requestLocation()
                    case .denied, .restricted:
                        showAlert = true
                    default:
                        break
                    }
                }) {
                    Text("Use current location")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .goodineButtonStyle(.mainbw)
                .cornerRadius(10)
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
                .onReceive(userLocationManager.$userLocation) { location in
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
                .padding(.bottom)
                
            Button(action: {
                onLocationAllowed()
            }) {
                Text("Skip")
                    .foregroundStyle(.mainbw)
                    .fontWeight(.semibold)
                    .overlay(
                        GeometryReader { geometry in
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [2]))
                                .frame(height: 1)
                                .offset(y: geometry.size.height + 2)
                                .foregroundColor(.mainbw)
                        }
                    )
            }                
            
        }
        .padding()
        
    }
}
