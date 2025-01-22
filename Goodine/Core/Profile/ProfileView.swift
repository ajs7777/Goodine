//
//  ProfileView.swift
//  Goodine
//
//  Created by Abhijit Saha on 22/01/25.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20.0){
                userDetails
                
                //membership section
                RoundedRectangle(cornerRadius: 15)
                    .fill(.orange.opacity(0.2))
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .onTapGesture {
                        
                    }
            }
            .padding(.horizontal)
            .padding(.top)
            
            //settings and other options
            NavigationLink {
                Text("Title")
                   // .navigationBarBackButtonHidden(true)
            } label: {
                VStack{
                    options(title: "My Account", image: "person")
                    options(title: "My Orders", image: "bag")
                    options(title: "Payments", image: "creditcard")
                    options(title: "Address", image: "location")
                    options(title: "Favourites", image: "heart")
                    options(title: "Promocodes", image: "tag")
                    options(title: "Settings", image: "gearshape")
                    options(title: "Help", image: "questionmark.circle")
                }
                .foregroundStyle(.black.opacity(0.8))
                .padding()
            }

            
        }
        // for dismiss the screen
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .bold()
                        .foregroundStyle(.black.opacity(0.8))
                }

            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}

extension ProfileView {
    private var userDetails: some View {
        HStack {
            VStack(alignment: .leading){
                Text("Abhijit Saha")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.black.opacity(0.8))
                Text("+91 9876543210")
                    .foregroundStyle(.gray)
                
            }
            Spacer()
            Image(systemName: "person")
                .resizable()
                .scaledToFill()
                .foregroundStyle(.black.opacity(0.8))
                .frame(width: 30, height: 30)
                .padding(20)
                .background(Color(.systemGray6))
                .clipShape(Circle())
        }
    }
    
}

//options

struct options : View {
    
    let title : String
    let image : String
    
    var body: some View{
        HStack(spacing: 20.0){
            Image(systemName: image)
                .resizable()
                .scaledToFill()
                .frame(width: 20, height: 20)
                .fontWeight(.semibold)
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right")
                
        } .padding(12)
    }
}
