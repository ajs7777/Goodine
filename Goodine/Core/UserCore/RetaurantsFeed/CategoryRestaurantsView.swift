import SwiftUI
import FirebaseFirestore
import CoreLocation

struct CategoryRestaurantsView: View {
    
    let categoryName: String
    var isVeg: Bool? = nil
    
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @State private var filteredNearbyRestaurants: [NearbyRestaurant] = []
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var userLocationManager = UserLocationManager()
    private let maxDistanceKm: Double = 15.0

    
    let db = Firestore.firestore()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Restaurants with \(categoryName)\(isVegText)")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredNearbyRestaurants.isEmpty {
                Text("No restaurants found with \(categoryName)\(isVegText)")
                    .foregroundStyle(.gray)
                    .padding()
            } else {
                ScrollView {
                    ForEach(filteredNearbyRestaurants) { item in
                        NavigationLink(
                            destination: RestaurantDetailView(restaurant: item.restaurant)
                                .navigationBarBackButtonHidden()
                        ) {
                            RestaurantsView(restaurant: [item.restaurant], distanceInKm: item.distanceInKm)
                                .tint(.primary)
                        }
                    }
                }
            }

        }
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
            fetchRestaurantsWithCategory()
        }
    }
    
    private var isVegText: String {
        guard let isVeg = isVeg else { return "" }
        return isVeg ? " (Veg)" : " (Non-Veg)"
    }

    private func fetchRestaurantsWithCategory() {
        guard let userLocation = userLocationManager.userLocation else {
            print("User location not available")
            isLoading = false
            return
        }

        isLoading = true
        filteredNearbyRestaurants = []

        let group = DispatchGroup()

        for restaurant in businessAuthVM.allRestaurants {
            group.enter()

            let restaurantRef = db.collection("business_users")
                .document(restaurant.id)
                .collection("restaurantLocations")
                .document("main")

            restaurantRef.getDocument { locationSnapshot, error in
                if let error = error {
                    print("❌ Error fetching location for \(restaurant.name): \(error.localizedDescription)")
                    group.leave()
                    return
                }

                guard let locData = locationSnapshot?.data(),
                      let lat = locData["latitude"] as? Double,
                      let lon = locData["longitude"] as? Double else {
                    print("⚠️ Missing location data for \(restaurant.name)")
                    group.leave()
                    return
                }

                let restaurantLocation = CLLocation(latitude: lat, longitude: lon)
                let distance = userLocation.distance(from: restaurantLocation) / 1000.0

                guard distance <= maxDistanceKm else {
                    group.leave()
                    return
                }

                // Now check menu items
                let menuRef = db.collection("business_users")
                    .document(restaurant.id)
                    .collection("menu")

                menuRef.getDocuments { snapshot, error in
                    defer { group.leave() }

                    if let error = error {
                        print("❌ Error fetching menu for \(restaurant.name): \(error.localizedDescription)")
                        return
                    }

                    guard let documents = snapshot?.documents else { return }

                    let hasMatchingItem: Bool

                    if categoryName.lowercased() == "veg" || categoryName.lowercased() == "non veg" {
                        hasMatchingItem = documents.contains { doc in
                            let data = doc.data()
                            let itemIsVeg = (data["isVeg"] as? Bool) ?? true
                            return isVeg == nil || itemIsVeg == isVeg
                        }
                    } else {
                        hasMatchingItem = documents.contains { doc in
                            let data = doc.data()
                            let itemName = (data["foodname"] as? String) ?? ""
                            let itemIsVeg = (data["isVeg"] as? Bool) ?? true
                            let matchesCategory = itemName.localizedCaseInsensitiveContains(categoryName)
                            let matchesVeg = isVeg == nil || itemIsVeg == isVeg
                            return matchesCategory && matchesVeg
                        }
                    }

                    if hasMatchingItem {
                        DispatchQueue.main.async {
                            let nearby = NearbyRestaurant(restaurant: restaurant, distanceInKm: distance)
                            filteredNearbyRestaurants.append(nearby)
                        }
                    }

                }
            }
        }

        group.notify(queue: .main) {
            isLoading = false
        }
    }


}

#Preview {
    CategoryRestaurantsView(categoryName: "Pizza") // 🍕 Example for Pizza
        .environmentObject(BusinessAuthViewModel())

    CategoryRestaurantsView(categoryName: "Veg", isVeg: true) // 🥦 Example for Veg
        .environmentObject(BusinessAuthViewModel())

    CategoryRestaurantsView(categoryName: "Non Veg", isVeg: false) // 🍗 Example for Non-Veg
        .environmentObject(BusinessAuthViewModel())
}
