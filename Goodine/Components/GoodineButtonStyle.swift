//
//  GoodineButtonStyle.swift
//  Goodine
//
//  Created by Abhijit Saha on 31/01/25.
//

import SwiftUI

struct GoodineButtonModifier: ViewModifier {
    
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .fontWeight(.semibold)
            .foregroundColor(.mainInvert)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

extension View {
    public func goodineButtonStyle(_ backgroundColor: Color) -> some View {
        modifier(GoodineButtonModifier(backgroundColor: backgroundColor))
    }
}

struct GoodineButtonStyle: View {
    var body: some View {
        Text("Hello, World!")
            .goodineButtonStyle(.mainbw)
    }
}

#Preview {
    GoodineButtonStyle()
}
