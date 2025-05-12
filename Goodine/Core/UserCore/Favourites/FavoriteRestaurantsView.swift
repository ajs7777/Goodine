import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

struct FavouriteRestaurantsView: View {
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @ObservedObject var userLocationManager = UserLocationManager()
    
    @State private var favouriteRestaurants: [NearbyRestaurant] = []
    @State private var isLoading = true

    let db = Firestore.firestore()
    private let maxDistanceKm: Double = 15.0

    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading) {
                Text("Favourites")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                if isLoading {
                    ProgressView("Loading favourites...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if favouriteRestaurants.isEmpty {
                    Text("You haven't added any favourites yet.")
                        .foregroundStyle(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(favouriteRestaurants) { item in
                            NavigationLink(
                                destination: RestaurantDetailView(restaurant: item.restaurant)
                                    .navigationBarBackButtonHidden()
                            ) {
                                FavouriteRestaurantRow(restaurant: [item.restaurant], distanceInKm: item.distanceInKm)
                                    .tint(.primary)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                fetchFavouriteRestaurants()
            }
        }

    }

    private func fetchFavouriteRestaurants() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            isLoading = false
            return
        }

        guard let userLocation = userLocationManager.userLocation else {
            print("User location not available")
            isLoading = false
            return
        }

        isLoading = true
        favouriteRestaurants = []

        let favRef = db.collection("users").document(userID).collection("Favourites")
        favRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching favourites: \(error.localizedDescription)")
                isLoading = false
                return
            }

            guard let docs = snapshot?.documents else {
                isLoading = false
                return
            }

            let favIDs = docs.map { $0.documentID }
            print("✅ FAVOURITE IDS: \(favIDs)")
            
            let allBusinessIDs = businessAuthVM.allRestaurants.map { $0.id }
            print("📋 ALL BUSINESS IDs: \(allBusinessIDs)")
            
            let matchingRestaurants = businessAuthVM.allRestaurants.filter { favIDs.contains($0.id) }

            let group = DispatchGroup()

            for restaurant in matchingRestaurants {
                group.enter()

                let locationRef = db.collection("business_users")
                    .document(restaurant.id)
                    .collection("restaurantLocations")
                    .document("main")

                locationRef.getDocument { locationSnapshot, error in
                    defer { group.leave() }

                    if let error = error {
                        print("❌ Error fetching location for \(restaurant.name): \(error.localizedDescription)")
                        return
                    }

                    guard let locData = locationSnapshot?.data(),
                          let lat = locData["latitude"] as? Double,
                          let lon = locData["longitude"] as? Double else {
                        print("⚠️ Missing location data for \(restaurant.name)")
                        return
                    }

                    let restaurantLocation = CLLocation(latitude: lat, longitude: lon)
                    let distance = userLocation.distance(from: restaurantLocation) / 1000.0

                    if distance <= maxDistanceKm {
                        DispatchQueue.main.async {
                            let nearby = NearbyRestaurant(restaurant: restaurant, distanceInKm: distance)
                            favouriteRestaurants.append(nearby)
                        }
                    }
                }
            }

            group.notify(queue: .main) {
                isLoading = false
            }
        }
    }
}
