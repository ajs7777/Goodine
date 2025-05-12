
import SwiftUI
import CoreLocation
import FirebaseFirestore

struct RestaurantsFeedView: View {
    
    let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    
    @State private var selectedPage = 0
    @State private var searchText = ""
    
    @State private var nearbyRestaurants: [NearbyRestaurant] = []
    
    private var filteredRestaurants: [NearbyRestaurant] {
        if searchText.isEmpty {
            return nearbyRestaurants
        } else {
            return nearbyRestaurants.filter {
                $0.restaurant.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    @State private var selectedRestaurant: Restaurant?
    @State private var showDetailView = false
    
    private var suggestedRestaurants: [NearbyRestaurant] {
        if searchText.isEmpty {
            return []
        } else {
            return nearbyRestaurants.filter {
                $0.restaurant.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    @State private var isLoading = true
    @State private var fetchError: String?
    private let db = Firestore.firestore()
    private let maxDistanceKm: Double = 15.0
    
    
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    @StateObject private var locationVM = LocationViewModel()
    @ObservedObject var userLocationManager = UserLocationManager()
    
    
    var body: some View {
        VStack {
            NavigationStack {
                ScrollView {
                    userSection
                    searchBar
                    categoriesSection
                    discountSection
                    //imageSection
                    restaurantsSection
                }
                .navigationDestination(isPresented: $showDetailView) {
                    if let restaurant = selectedRestaurant {
                        RestaurantDetailView(restaurant: restaurant)
                            .navigationBarBackButtonHidden()
                    }
                }


            }
        }
        .onReceive(userLocationManager.$userLocation
            .debounce(for: .seconds(1), scheduler: RunLoop.main)) { location in
            guard let location = location else { return }
            fetchNearbyRestaurants(userLocation: location)
        }
        
    }
    
    func fetchNearbyRestaurants(userLocation: CLLocation) {
        nearbyRestaurants = []
        isLoading = true
        fetchError = nil

        let group = DispatchGroup()

        for restaurant in businessAuthVM.allRestaurants {
            group.enter()

            db.collection("business_users")
                .document(restaurant.id)
                .collection("restaurantLocations")
                .document("main")
                .getDocument { snapshot, error in
                    defer { group.leave() }

                    guard error == nil else {
                        print("❌ Error fetching location for \(restaurant.name): \(error!.localizedDescription)")
                        return
                    }

                    guard let data = snapshot?.data(),
                          let lat = data["latitude"] as? Double,
                          let lon = data["longitude"] as? Double else {
                        print("⚠️ Skipping \(restaurant.name): Missing or invalid location data.")
                        return
                    }

                    let restaurantLocation = CLLocation(latitude: lat, longitude: lon)
                    let distance = userLocation.distance(from: restaurantLocation) / 1000.0
                    print("📍 \(restaurant.name): \(distance) km away")

                    if distance <= maxDistanceKm {
                        DispatchQueue.main.async {
                            if !nearbyRestaurants.contains(where: { $0.id == restaurant.id }) {
                                nearbyRestaurants.append(NearbyRestaurant(restaurant: restaurant, distanceInKm: distance))
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
    RestaurantsFeedView()
        .environmentObject(BusinessAuthViewModel())
        .environmentObject(UserLocationManager())
}

extension RestaurantsFeedView {
    
    private var userSection: some View {
        HStack {
            VStack(alignment: .leading){
                Text(locationVM.cityName)
                    .foregroundStyle(.gray)
                    .font(.caption)
                HStack{
                    Text(locationVM.areaName)
                        .font(.title3)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.down")
                        .font(.footnote)
                        .fontWeight(.semibold)
                    
                }
            }
            Spacer()
            NavigationLink {
                ProfileView()
                    .navigationBarBackButtonHidden()
            } label: {
                UserCircleImage(size: .large)
                
            }
        } .padding(.horizontal)
    }
    
    private var searchBar: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search for restaurants", text: $searchText)
                    .font(.body)
                    .padding(.leading, 40)
                    .padding(.trailing, 80)
                    .frame(height: 50)
                    .background(.mainbw.opacity(0.1))
                    .clipShape(Capsule())
                    .overlay {
                        Image(systemName: "magnifyingglass")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 15)
//                        Spacer()
//                        Button {
//                            // Mic action
//                        } label: {
//                            Image(systemName: "mic.fill")
//                        }
//                        .tint(.mainbw)
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        .padding(.trailing, 50)
//
//                        Button {
//                            // Filter action
//                        } label: {
//                            Image(systemName: "slider.vertical.3")
//                        }
//                        .tint(.mainbw)
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        .padding(.trailing, 18)
                    }
            }

            // Suggestions dropdown
            if !suggestedRestaurants.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(suggestedRestaurants.prefix(5)) { item in
                        Button(action: {
                            selectedRestaurant = item.restaurant
                            searchText = ""
                            showDetailView = true
                        }) {
                            Text(item.restaurant.name)
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .tint(.black)
                    }
                }
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 2)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var categoriesSection: some View {
        let categories = [
            ("biriyani", "Biriyani"),
            ("pizza", "Pizza"),
            ("burger", "Burger"),
            ("momo", "Momo"),
            ("veg", "Veg"),
            ("nonveg", "Non Veg"),
            ("rolls", "Rolls"),
            ("noodles", "Noodles")
        ]
        
        return Grid(horizontalSpacing: 20, verticalSpacing: 18) {
            ForEach(0..<2) { row in
                GridRow {
                    ForEach(0..<4) { column in
                        let index = row * 4 + column
                        if index < categories.count {
                            let category = categories[index]
                            NavigationLink {
                                CategoryRestaurantsView(categoryName: category.1)
                                    .navigationBarBackButtonHidden()
                            } label: {
                                VStack(spacing: 5.0) {
                                    Image(category.0)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75)
                                        .clipShape(Circle())
                                    Text(category.1)
                                        .font(.footnote)
                                        .fontWeight(.medium)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private var discountSection: some View {
        let cards: [(String, String, String, Color)] = [
            ("Discount-1", "Family Friendly", "Restaurants", Color("darkblue")),
            ("Discount-2", "Couple Friendly", "Restaurants", .red),
            ("Discount-3", "Dine in Available", "Near You", .orange)
        ]

        return VStack {
            TabView(selection: $selectedPage) {
                ForEach(Array(cards.enumerated()), id: \.offset) { index, card in
                    NavigationLink(
                        destination: FeatureRestaurantsView(featureTag: card.1)
                            .environmentObject(businessAuthVM)
                    ) {
                        DiscountCardView(
                            imageName: card.0,
                            subtitle: card.1,
                            description: card.2,
                            gradient: card.3
                        )
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 170)

            HStack(spacing: 6) {
                ForEach(0..<cards.count, id: \.self) { index in
                    Capsule()
                        .fill(selectedPage == index ? Color.mainbw : Color.gray.opacity(0.3))
                        .frame(width: selectedPage == index ? 25 : 10, height: 5)
                }
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut) {
                selectedPage = (selectedPage + 1) % cards.count
            }
        }
    }
    
    private var imageSection: some View {
        VStack(alignment: .leading) {
            Text("Must Try Places")
                .foregroundStyle(.mainbw)
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12.0) {
                    ForEach(businessAuthVM.allRestaurants) { restaurant in
                        MustTryPlaces( restaurant: restaurant)
                    }
                    
                } .padding(.horizontal)
            }
        }
    }
    
    private var restaurantsSection: some View {
        VStack(alignment: .leading) {
            Text("Restaurants To Explore")
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading)
            
            VStack(alignment: .leading) {
                if isLoading {
                    ProgressView("Fetching nearby places...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = fetchError {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else if nearbyRestaurants.isEmpty {
                    Text("No nearby restaurants found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(filteredRestaurants) { item in
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
        .padding(.top, 20)
        
       
        
    }
    
}

struct NearbyRestaurant: Identifiable {
    var id: String { restaurant.id }
    let restaurant: Restaurant
    let distanceInKm: Double
}
