import SwiftUI
import FirebaseFirestore

struct CategoryRestaurantsView: View {
    
    let categoryName: String
    var isVeg: Bool? = nil
    
    @EnvironmentObject var businessAuthVM: BusinessAuthViewModel
    @State private var filteredRestaurants: [Restaurant] = []
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss
    
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
            } else if filteredRestaurants.isEmpty {
                Text("No restaurants found with \(categoryName)\(isVegText)")
                    .foregroundStyle(.gray)
                    .padding()
            } else {
                ScrollView {
                    ForEach(filteredRestaurants) { restaurant in
                        NavigationLink(
                            destination: RestaurantDetailView(restaurant: restaurant)
                                .navigationBarBackButtonHidden()
                        ) {
                            RestaurantsView(restaurant: [restaurant])
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
        isLoading = true
        filteredRestaurants = []

        let group = DispatchGroup()

        for restaurant in businessAuthVM.allRestaurants {
            group.enter()

            db.collection("business_users")
                .document(restaurant.id)
                .collection("menu")
                .getDocuments { snapshot, error in
                    defer { group.leave() }

                    if let error = error {
                        print("❌ Error fetching menu for restaurant \(restaurant.name): \(error.localizedDescription)")
                        return
                    }

                    guard let documents = snapshot?.documents else { return }

                    let hasMatchingItem: Bool

                    if categoryName.lowercased() == "veg" || categoryName.lowercased() == "non veg" {
                        // Only check based on isVeg
                        hasMatchingItem = documents.contains { doc in
                            let data = doc.data()
                            let itemIsVeg = (data["isVeg"] as? Bool) ?? true
                            return isVeg == nil || itemIsVeg == isVeg
                        }
                    } else {
                        // Normal category check (like Pizza, Burger, etc)
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
                            self.filteredRestaurants.append(restaurant)
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
