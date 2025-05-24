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
    @StateObject private var viewModel = FeatureRestaurantsViewModel()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(featureTag.capitalized) Restaurants")
                .font(.title).bold().padding()

            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.nearbyFeatureRestaurants.isEmpty {
                Text("No restaurants found with feature: \(featureTag)")
                    .foregroundStyle(.gray).padding()
            } else {
                ScrollView {
                    ForEach(viewModel.nearbyFeatureRestaurants) { item in
                        NavigationLink(
                            destination: RestaurantDetailView(restaurant: item.restaurant, distanceInKm: item.distanceInKm)
                                .navigationBarBackButtonHidden()
                        ) {
                            RestaurantsView(restaurant: [item.restaurant], distanceInKm: item.distanceInKm)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .enableSwipeBackGesture()
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
        .onAppear {
            if let location = userLocationManager.userLocation,
               viewModel.nearbyFeatureRestaurants.isEmpty {
                viewModel.fetchNearbyFeatureRestaurants(
                    featureTag: featureTag,
                    userLocation: location,
                    allRestaurants: businessAuthVM.allRestaurants
                )
            }
        }
        
        .onChange(of: userLocationManager.userLocation) {
            if let location = userLocationManager.userLocation,
               viewModel.nearbyFeatureRestaurants.isEmpty {
                viewModel.fetchNearbyFeatureRestaurants(
                    featureTag: featureTag,
                    userLocation: location,
                    allRestaurants: businessAuthVM.allRestaurants
                )
            }
        }
    }
}
