//
//  LocationViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 05/05/25.
//
import Foundation
import Firebase
import CoreLocation
import FirebaseAuth

class LocationViewModel: ObservableObject {
    @Published var cityName: String = "City"
    @Published var areaName: String = "Select Location"
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        fetchLocation()
    }

    func fetchLocation() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        listener = db.collection("users")
            .document(userId)
            .collection("userLocations")
            .document("locations")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let data = snapshot?.data() else { return }

                let latitude = data["latitude"] as? Double ?? 0.0
                let longitude = data["longitude"] as? Double ?? 0.0

                self.getAddressFromCoordinates(latitude: latitude, longitude: longitude)
            }
    }

    func getAddressFromCoordinates(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first, error == nil else { return }
            DispatchQueue.main.async {
                self?.cityName = placemark.locality ?? "Unknown City"
                self?.areaName = placemark.thoroughfare ?? "Unknown Area"
            }
        }
    }

    deinit {
        listener?.remove()
    }
}
