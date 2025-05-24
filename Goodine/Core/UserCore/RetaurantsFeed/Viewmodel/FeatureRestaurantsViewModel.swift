//
//  FeatureRestaurantsViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 20/05/25.
//


import Foundation
import CoreLocation

class FeatureRestaurantsViewModel: ObservableObject {
    @Published var nearbyFeatureRestaurants: [NearbyRestaurant] = []
    @Published var isLoading = false

    private let service = RestaurantsService()

    func fetchNearbyFeatureRestaurants(featureTag: String, userLocation: CLLocation?, allRestaurants: [Restaurant]) {
        guard let userLocation else {
            isLoading = false
            return
        }

        isLoading = true
        service.fetchRestaurantsWithFeature(featureTag: featureTag, userLocation: userLocation, allRestaurants: allRestaurants) { results in
            self.nearbyFeatureRestaurants = results
            self.isLoading = false
        }
    }
}

