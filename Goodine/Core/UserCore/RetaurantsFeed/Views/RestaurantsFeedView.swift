
import SwiftUI
import CoreLocation
import FirebaseFirestore
import Shimmer

struct RestaurantsFeedView: View {
    
    let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    
    @State private var selectedPage = 0
    @State private var searchText = ""
    
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    
    @EnvironmentObject var nearbyVM: NearbyRestaurantsViewModel
        
    @State private var selectedRestaurant: Restaurant?
    @State private var showDetailView = false
    
    private var suggestedRestaurants: [NearbyRestaurant] {
        if searchText.isEmpty {
            return []
        } else {
            return nearbyVM.nearbyRestaurants.filter {
                $0.restaurant.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    
    private let db = Firestore.firestore()
    private let maxDistanceKm: Double = 15.0
        
    @EnvironmentObject var userLocationManager: UserLocationManager
    @EnvironmentObject var locationVM: LocationViewModel
    
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
                              
                
            }
        }
        .onReceive(userLocationManager.$userLocation
            .debounce(for: .seconds(1), scheduler: RunLoop.main)) { location in
                guard let location = location else { return }
                nearbyVM.fetchNearbyRestaurants(
                    userLocation: location,
                    allRestaurants: businessAuthVM.allRestaurants
                )
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
                        Spacer()
                        Button {
                            if isRecording {
                                speechRecognizer.stopRecording()
                            } else {
                                try? speechRecognizer.startRecording()
                            }
                            isRecording.toggle()
                        } label: {
                            Image(systemName: "mic.fill")
                                .foregroundColor(isRecording ? .red : .mainbw.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 22)
                        //.padding(.trailing, 50)
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
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(suggestedRestaurants.prefix(5)) { item in
                        Button(action: {
                            selectedRestaurant = item.restaurant
                            searchText = ""
                            showDetailView = true
                        }) {
                            HStack {
                                Image("businessicon")
                                    .resizable()
                                    .frame(width: 24, height: 37)
                                    .padding(.leading)
                                
                                Text(item.restaurant.name)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.mainbw.opacity(0.8))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .onReceive(speechRecognizer.$recognizedText) { newText in
            searchText = newText
        }
        
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
                                let isVeg: Bool? = {
                                    switch category.0.lowercased() {
                                    case "veg": return true
                                    case "nonveg": return false
                                    default: return nil
                                    }
                                }()
                                
                                CategoryRestaurantsView(
                                    categoryName: category.1,
                                    isVeg: isVeg
                                )
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Restaurants To Explore")
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading)
            
            if nearbyVM.isLoading || !nearbyVM.hasLoaded {
                // Skeleton View
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 150)
                        .padding(.horizontal)
                        .shimmering()
                }
            } else if let error = nearbyVM.fetchError {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else if nearbyVM.nearbyRestaurants.isEmpty {
                Text("No nearby restaurants found.")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.gray)
            } else {
                ForEach(nearbyVM.nearbyRestaurants) { item in
                    NavigationLink(
                        destination: RestaurantDetailView(restaurant: item.restaurant, distanceInKm: item.distanceInKm)
                           
                    ) {
                        RestaurantsView(
                            restaurant: [item.restaurant],
                            distanceInKm: item.distanceInKm
                        )
                        .tint(.primary)
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
