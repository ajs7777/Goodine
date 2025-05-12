//
//  FeatureRestaurantsView.swift
//  Goodine
//
//  Created by Abhijit Saha on 10/05/25.
//
import SwiftUI
import FirebaseFirestore
import CoreLocation

struct FeatureRestaurantsView: View {
    let featureTag: String

    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @ObservedObject var userLocationManager = UserLocationManager()
    @State private var nearbyFeatureRestaurants: [NearbyRestaurant] = []
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss

    private let maxDistanceKm: Double = 15.0
    let db = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(featureTag.capitalized) Restaurants")
                .font(.title).bold().padding()

            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if nearbyFeatureRestaurants.isEmpty {
                Text("No restaurants found with feature: \(featureTag)")
                    .foregroundStyle(.gray).padding()
            } else {
                ScrollView {
                    ForEach(nearbyFeatureRestaurants) { item in
                        NavigationLink(
                            destination: RestaurantDetailView(restaurant: item.restaurant)
                                .navigationBarBackButtonHidden()
                        ) {
                            RestaurantsView(restaurant: [item.restaurant], distanceInKm: item.distanceInKm)
                        }
                    }
                }
            }
        }
        .onAppear(perform: fetchFeatureRestaurants)
    }

    private func fetchFeatureRestaurants() {
        guard let userLocation = userLocationManager.userLocation else {
            isLoading = false
            return
        }

        isLoading = true
        nearbyFeatureRestaurants = []

        let group = DispatchGroup()

        for restaurant in businessAuthVM.allRestaurants {
            group.enter()

            let locationRef = db.collection("business_users")
                .document(restaurant.id)
                .collection("restaurantLocations")
                .document("main")

            locationRef.getDocument { locationSnapshot, error in
                if let locData = locationSnapshot?.data(),
                   let lat = locData["latitude"] as? Double,
                   let lon = locData["longitude"] as? Double {
                    
                    let restaurantLocation = CLLocation(latitude: lat, longitude: lon)
                    let distance = userLocation.distance(from: restaurantLocation) / 1000.0

                    guard distance <= maxDistanceKm else {
                        group.leave()
                        return
                    }

                    let docRef = db.collection("business_users").document(restaurant.id)
                    docRef.getDocument { snapshot, error in
                        defer { group.leave() }

                        if let data = snapshot?.data(),
                           let features = data["features"] as? [String],
                           features.map({ $0.lowercased() }).contains(featureTag.lowercased()) {
                            DispatchQueue.main.async {
                                nearbyFeatureRestaurants.append(NearbyRestaurant(restaurant: restaurant, distanceInKm: distance))
                            }
                        }
                    }

                } else {
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            isLoading = false
        }
    }
}
