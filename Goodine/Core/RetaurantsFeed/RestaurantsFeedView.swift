//
//  RestaurantsFeedView.swift
//  Goodine
//
//  Created by Abhijit Saha on 22/01/25.
//

import SwiftUI

struct RestaurantsFeedView: View {
    
    let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
    
    @State private var selectedPage = 0
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            NavigationStack {
                ScrollView {
                    userSection
                    searchBar
                    categoriesSection
                    discountSection
                    MustTryPlaces()
                    restaurantsSection
                        
                }               
                
            }
        }
    }
}

#Preview {
    RestaurantsFeedView()
}

extension RestaurantsFeedView {
    
    private var userSection: some View {
        HStack {
            VStack(alignment: .leading){
                Text("Dine In Now")
                    .foregroundStyle(.gray)
                    .font(.caption)
                HStack{
                    Text("Hsr Layout")
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
                UserCircleImage(size: .small)

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
        .padding(.top, 8)
    }
    
    private var categoriesSection : some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 18) {
                ForEach(0..<2) { row in
                    GridRow {
                        ForEach(0..<4) { column in
                            VStack(spacing: 5.0){
                                Image("nonveg")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 75, height: 75)
                                    .clipShape(Circle())
                                Text("Non Veg")
                                    .font(.footnote)
                                    .fontWeight(.medium)
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
    
    private var restaurantsSection: some View {
        VStack(alignment: .leading) {
            Text("Restaurants To Explore")
                .font(.title)
                .fontWeight(.bold)
                .padding(.leading)
        
            ForEach(0 ... 20, id: \.self) { restaurant in
                NavigationLink(
                    destination: RestaurantDetailView()
                        .navigationBarBackButtonHidden()

                ) {
                    RestaurantsView()
                        .tint(.primary)
                }
                                                           
        }
        }
        .padding(.top, 20)
        
    }
    
}
