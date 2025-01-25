//
//  RestaurantsFeedView.swift
//  Goodine
//
//  Created by Abhijit Saha on 22/01/25.
//

import SwiftUI

struct RestaurantsFeedView: View {
    
    let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    
    @State private var selectedPage = 0
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            NavigationStack {
                ScrollView {
                    searchBar
                    categoriesSextion
                    discountSection
                    suggestionSection
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        VStack(alignment: .leading){
                            Text("Dine In Now")
                                .foregroundStyle(.gray)
                                .font(.caption)
                            HStack{
                                Text("Hsr Layout")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            ProfileView()
                                .navigationBarBackButtonHidden()
                        } label: {
                            UserCircleImage(size: .small)

                        }
 
                    }
                }
            }
        }
    }
}

#Preview {
    RestaurantsFeedView()
}

extension RestaurantsFeedView {
    private var searchBar: some View {
        HStack {
            TextField("Search for restaurants", text: $searchText)
                .font(.footnote)
                .padding(.leading, 40)
                .padding(.trailing, 80)
                .frame(maxWidth : .infinity)
                .frame(height: 45)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
                .overlay {
                    Image(systemName: "magnifyingglass")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "mic")
                    }
                    .tint(.black.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 50)
                    Button {
                        
                    } label: {
                        Image(systemName: "slider.vertical.3")
                    }
                    .tint(.black.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 18)

                }
        }
        .padding()
    }
    private var categoriesSextion : some View {
        Grid(horizontalSpacing: 30, verticalSpacing: 20) {
                ForEach(0..<2) { row in
                    GridRow {
                        ForEach(0..<4) { column in
                            VStack(spacing: 5.0){
                                Image("nonveg")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 65, height: 65)
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
                        .fill(selectedPage == index ? Color.black.opacity(0.8) : Color.gray.opacity(0.3))
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
    private var suggestionSection :  some View {
        
        ScrollView {
                Text("Must Try Places")
                    .font(.title3)
                    .bold()
                ScrollView(.horizontal, showsIndicators: false) {
                ForEach(0..<10) { _ in
                    
                        MustTryPlaces()
                    }
                }
            }
        
    }
}
