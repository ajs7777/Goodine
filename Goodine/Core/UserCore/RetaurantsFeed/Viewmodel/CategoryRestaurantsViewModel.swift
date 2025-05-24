//
//  CategoryRestaurantsViewModel.swift
//  Goodine
//
//  Created by Abhijit Saha on 16/05/25.
//


import Foundation
import CoreLocation

class CategoryRestaurantsViewModel: ObservableObject {
    @Published var filteredNearbyRestaurants: [NearbyRestaurant] = []
    @Published var isLoading = false

    private let service = RestaurantsService()

    func fetchRestaurants(categoryName: String, isVeg: Bool?, userLocation: CLLocation, allRestaurants: [Restaurant]) {
        isLoading = true
        service.fetchRestaurantsMatchingCategory(
            categoryName: categoryName,
            isVeg: isVeg,
            userLocation: userLocation,
            allRestaurants: allRestaurants
        ) { results in
            self.filteredNearbyRestaurants = results
            self.isLoading = false
        }
    }
}
