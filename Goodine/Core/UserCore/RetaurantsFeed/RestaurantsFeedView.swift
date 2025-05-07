
import SwiftUI

struct RestaurantsFeedView: View {
    
    let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    
    @State private var selectedPage = 0
    @State private var searchText = ""
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    @StateObject private var locationVM = LocationViewModel()
    
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
        .onAppear {
            Task{
                await businessAuthVM.fetchAllRestaurants()
            }
        }
        
    }
}

#Preview {
    RestaurantsFeedView()
        .environmentObject(BusinessAuthViewModel())
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
                        .font(.title2)
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
        HStack {
            TextField("Search for restaurants", text: $searchText)
                .font(.body)
                .padding(.leading, 40)
                .padding(.trailing, 80)
                .frame(maxWidth : .infinity)
                .frame(height: 50)
                .background(.mainbw.opacity(0.1))
                .clipShape(Capsule())
                .overlay {
                    Image(systemName: "magnifyingglass")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "mic.fill")
                    }
                    .tint(.mainbw)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 50)
                    Button {
                        
                    } label: {
                        Image(systemName: "slider.vertical.3")
                    }
                    .tint(.mainbw)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 18)
                    
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
        VStack {
            TabView(selection: $selectedPage) {
                ForEach(0..<3) { index in
                    DiscountCardView()
                        .tag(index)
                }
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 170)
            
            
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Capsule()
                        .fill(selectedPage == index ? Color.mainbw : Color.gray.opacity(0.3))
                        .frame(width: selectedPage == index ? 25 : 10, height: 5)
                }
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut) {
                selectedPage = (selectedPage + 1) % 3
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
            
            ForEach(businessAuthVM.allRestaurants) { restaurant in
                NavigationLink(
                    destination: RestaurantDetailView(restaurant: restaurant)
                        .navigationBarBackButtonHidden()
                    
                ) {
                    RestaurantsView(restaurant: [restaurant])
                        .tint(.primary)
                }
                
            }
        }
        .padding(.top, 20)
        
    }
    
}
