
import SwiftUI
import FirebaseFirestore
import CoreLocation

struct CategoryRestaurantsView: View {
    
    let categoryName: String
    var isVeg: Bool? = nil
    
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @ObservedObject var userLocationManager = UserLocationManager()
    @StateObject private var viewModel = CategoryRestaurantsViewModel()
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            Text("Restaurants with \(categoryName)\(isVegText)")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            if viewModel.isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredNearbyRestaurants.isEmpty {
                Text("No restaurants found with \(categoryName)\(isVegText)")
                    .foregroundStyle(.gray)
                    .padding()
            } else {
                ScrollView {
                    ForEach(viewModel.filteredNearbyRestaurants) { item in
                        NavigationLink(
                            destination: RestaurantDetailView(restaurant: item.restaurant, distanceInKm: item.distanceInKm)
                                .navigationBarBackButtonHidden()
                        ) {
                            RestaurantsView(restaurant: [item.restaurant], distanceInKm: item.distanceInKm)
                                .tint(.primary)
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
               viewModel.filteredNearbyRestaurants.isEmpty {
                viewModel.fetchRestaurants(
                    categoryName: categoryName,
                    isVeg: isVeg,
                    userLocation: location,
                    allRestaurants: businessAuthVM.allRestaurants
                )
            }
        }

        .onChange(of: userLocationManager.userLocation) {
            if let location = userLocationManager.userLocation,
               viewModel.filteredNearbyRestaurants.isEmpty {
                viewModel.fetchRestaurants(
                    categoryName: categoryName,
                    isVeg: isVeg,
                    userLocation: location,
                    allRestaurants: businessAuthVM.allRestaurants
                )
            }
        }
    }
    
    private var isVegText: String {
        guard let isVeg = isVeg else { return "" }
        return isVeg ? " (Veg)" : " (Non Veg)"
    }
}
