//
//  VegNonVegIcon.swift
//  Goodine
//
//  Created by Abhijit Saha on 19/02/25.
//

import SwiftUI

struct VegNonVegIcon: View {
    
    let size : CGFloat
    let color : Color
    
    var body: some View {
        Rectangle()
            .fill(.white)
            .stroke(color, lineWidth: 2)
            .frame(width: size, height: size)
            .overlay(alignment: .center) {
                Circle()
                    .fill(color)
                    .padding(3)
            }
    }
}

#Preview {
    VegNonVegIcon(size: 18, color: .red)
}
