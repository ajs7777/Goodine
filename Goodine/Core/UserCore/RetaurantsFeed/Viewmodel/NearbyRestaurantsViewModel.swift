//
//  NearbyRestaurantsViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 13/05/25.
//


import Foundation
import CoreLocation

class NearbyRestaurantsViewModel: ObservableObject {
    @Published var nearbyRestaurants: [NearbyRestaurant] = []
    @Published var isLoading = false
    @Published var fetchError: String?
    @Published var hasLoaded = false

    private let service = RestaurantsService()
    private var hasFetched = false

    func fetchNearbyRestaurants(userLocation: CLLocation, allRestaurants: [Restaurant]) {
        guard !hasFetched else { return }
        hasFetched = true

        isLoading = true
        fetchError = nil
        hasLoaded = false

        service.fetchNearbyRestaurants(userLocation: userLocation, allRestaurants: allRestaurants) { results in
            self.nearbyRestaurants = results
            self.isLoading = false
            self.hasLoaded = true
        }
    }
}
