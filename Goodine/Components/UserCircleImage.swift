//
//  UserCircleImage.swift
//  Goodine
//
//  Created by Abhijit Saha on 24/01/25.
//

import SwiftUI
import Kingfisher

enum Sizeoptions {
    case small
    case medium
    case large
    
    var dimension: CGFloat {
        switch self {
        case .small:
            return 20
        case .medium:
            return 30
        case .large:
            return 40
        }
    }
}

struct UserCircleImage: View {
    
    @State var size: Sizeoptions
    @EnvironmentObject var userAuthVM : AuthViewModel
    
    var body: some View {
        if let imageUrl = userAuthVM.userdata?.profileImageURL, let url = URL(string: imageUrl) {
            // Profile image from Firebase using Kingfisher
            KFImage(url)
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            // Placeholder
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size.dimension, height: size.dimension)
                .foregroundColor(Color(.systemGray3))
        }
    }
}

#Preview {
    UserCircleImage(size: .small)
}

