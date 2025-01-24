//
//  UserCircleImage.swift
//  Goodine
//
//  Created by Abhijit Saha on 24/01/25.
//

import SwiftUI

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
            return 50
        }
    }
}

struct UserCircleImage: View {
    
    @State var size: Sizeoptions
    
    var body: some View {
        Image(systemName: "person")
            .resizable()
            .scaledToFill()
            .fontWeight(.semibold)
            .foregroundStyle(.black.opacity(0.7))
            .frame(width: size.dimension, height: size.dimension)
            .padding(10)
            .background(Color(.systemGray5))
            .clipShape(Circle())
    }
}

#Preview {
    UserCircleImage(size: .small)
}
