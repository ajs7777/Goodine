//
//  FavouriteRestaurantsViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 16/05/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

class FavouriteRestaurantsViewModel: ObservableObject {
    @Published var favouriteRestaurants: [NearbyRestaurant] = []
    @Published var isLoading: Bool = true

    private let db = Firestore.firestore()
    private let maxDistanceKm: Double = 15.0

    func fetchFavourites(for userLocation: CLLocation?, allRestaurants: [Restaurant]) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            self.isLoading = false
            return
        }

        guard let userLocation = userLocation else {
            print("User location not available")
            self.isLoading = false
            return
        }

        isLoading = true
        favouriteRestaurants = []

        let favRef = db.collection("users").document(userID).collection("Favourites")
        favRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching favourites: \(error.localizedDescription)")
                self.isLoading = false
                return
            }

            guard let docs = snapshot?.documents else {
                self.isLoading = false
                return
            }

            let favIDs = docs.map { $0.documentID }
            let matchingRestaurants = allRestaurants.filter { favIDs.contains($0.id) }

            let group = DispatchGroup()
            var results: [NearbyRestaurant] = []

            for restaurant in matchingRestaurants {
                group.enter()

                let locationRef = self.db.collection("business_users")
                    .document(restaurant.id)
                    .collection("restaurantLocations")
                    .document("main")

                locationRef.getDocument { snapshot, error in
                    defer { group.leave() }

                    if let data = snapshot?.data(),
                       let lat = data["latitude"] as? Double,
                       let lon = data["longitude"] as? Double {

                        let restaurantLocation = CLLocation(latitude: lat, longitude: lon)
                        let distance = userLocation.distance(from: restaurantLocation) / 1000.0

                        if distance <= self.maxDistanceKm {
                            results.append(NearbyRestaurant(restaurant: restaurant, distanceInKm: distance))
                        }
                    }
                }
            }

            group.notify(queue: .main) {
                self.favouriteRestaurants = results
                self.isLoading = false
            }
        }
    }
}
