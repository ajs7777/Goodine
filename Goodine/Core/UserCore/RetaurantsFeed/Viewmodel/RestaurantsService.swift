//
//  RestaurantsService.swift
//  Goodine
//
//  Created by Abhijit Saha on 20/05/25.
//


import Foundation
import FirebaseFirestore
import CoreLocation

class RestaurantsService {
    private let db = Firestore.firestore()
    private let maxDistanceKm: Double = 15.0

    func fetchNearbyRestaurants(
        userLocation: CLLocation,
        allRestaurants: [Restaurant],
        completion: @escaping ([NearbyRestaurant]) -> Void
    ) {
        var results: [NearbyRestaurant] = []
        let group = DispatchGroup()

        for restaurant in allRestaurants {
            group.enter()
            fetchRestaurantLocation(restaurantID: restaurant.id) { location in
                defer { group.leave() }

                guard let location else { return }
                let distance = userLocation.distance(from: location) / 1000.0

                if distance <= self.maxDistanceKm {
                    results.append(NearbyRestaurant(restaurant: restaurant, distanceInKm: distance))
                }
            }
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }

    func fetchRestaurantsMatchingCategory(
        categoryName: String,
        isVeg: Bool?,
        userLocation: CLLocation,
        allRestaurants: [Restaurant],
        completion: @escaping ([NearbyRestaurant]) -> Void
    ) {
        var results: [NearbyRestaurant] = []
        let group = DispatchGroup()

        for restaurant in allRestaurants {
            group.enter()
            fetchRestaurantLocation(restaurantID: restaurant.id) { location in
                guard let location else {
                    group.leave()
                    return
                }

                let distance = userLocation.distance(from: location) / 1000.0
                guard distance <= self.maxDistanceKm else {
                    group.leave()
                    return
                }

                let menuRef = self.db.collection("business_users")
                    .document(restaurant.id)
                    .collection("menu")

                menuRef.getDocuments { snapshot, error in
                    defer { group.leave() }

                    guard let documents = snapshot?.documents else { return }

                    let categoryLower = categoryName.lowercased()
                    let hasMatch = documents.contains { doc in
                        let data = doc.data()
                        let itemName = (data["foodname"] as? String) ?? ""
                        let itemIsVeg = (data["isVeg"] as? Bool) ?? true

                        let matchesVeg = isVeg == nil || itemIsVeg == isVeg
                        let matchesCategory = (categoryLower == "veg" || categoryLower == "non veg" || categoryLower == "nonveg") ||
                            categoryName.isEmpty ||
                            itemName.localizedCaseInsensitiveContains(categoryLower)

                        return matchesVeg && matchesCategory
                    }

                    if hasMatch {
                        results.append(NearbyRestaurant(restaurant: restaurant, distanceInKm: distance))
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }

    func fetchRestaurantsWithFeature(
        featureTag: String,
        userLocation: CLLocation,
        allRestaurants: [Restaurant],
        completion: @escaping ([NearbyRestaurant]) -> Void
    ) {
        var results: [NearbyRestaurant] = []
        let group = DispatchGroup()

        for restaurant in allRestaurants {
            group.enter()
            fetchRestaurantLocation(restaurantID: restaurant.id) { location in
                guard let location else {
                    group.leave()
                    return
                }

                let distance = userLocation.distance(from: location) / 1000.0
                guard distance <= self.maxDistanceKm else {
                    group.leave()
                    return
                }

                let docRef = self.db.collection("business_users").document(restaurant.id)
                docRef.getDocument { snapshot, _ in
                    defer { group.leave() }

                    if let data = snapshot?.data(),
                       let features = data["features"] as? [String],
                       features.map({ $0.lowercased() }).contains(featureTag.lowercased()) {
                        results.append(NearbyRestaurant(restaurant: restaurant, distanceInKm: distance))
                    }
                }
            }
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }

    private func fetchRestaurantLocation(restaurantID: String, completion: @escaping (CLLocation?) -> Void) {
        let locationRef = db.collection("business_users")
            .document(restaurantID)
            .collection("restaurantLocations")
            .document("main")

        locationRef.getDocument { snapshot, _ in
            if let data = snapshot?.data(),
               let lat = data["latitude"] as? Double,
               let lon = data["longitude"] as? Double {
                completion(CLLocation(latitude: lat, longitude: lon))
            } else {
                completion(nil)
            }
        }
    }
}
