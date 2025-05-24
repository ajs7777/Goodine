import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

struct FavouriteRestaurantsView: View {
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @ObservedObject var userLocationManager = UserLocationManager()
    @StateObject private var viewModel = FavouriteRestaurantsViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Favourites")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                if viewModel.isLoading {
                    ScrollView {
                           VStack {
                               ForEach(0..<5) { _ in
                                   FavouriteRestaurantRowSkeleton()
                               }
                           }
                       }
                } else if viewModel.favouriteRestaurants.isEmpty {
                    Text("You haven't added any favourites yet.")
                        .foregroundStyle(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(viewModel.favouriteRestaurants) { item in
                            NavigationLink(
                                destination: RestaurantDetailView(restaurant: item.restaurant, distanceInKm: item.distanceInKm)
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
        .onReceive(userLocationManager.$userLocation.combineLatest(businessAuthVM.$allRestaurants)) { (location, restaurants) in
            if let location = location, !restaurants.isEmpty {
                viewModel.fetchFavourites(for: location, allRestaurants: restaurants)
            }
        }


    }
}


struct FavouriteRestaurantRowSkeleton: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 16)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 12)
            }
            .padding(.leading, 8)

            Spacer()
        }
        .padding()
        .redacted(reason: .placeholder)
        .shimmering() // Optional: custom modifier for shimmer effect
    }
}
