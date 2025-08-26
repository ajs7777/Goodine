//
//  PaymentsView.swift
//  Goodine
//
//  Created by Abhijit Saha on 03/06/25.
//

import SwiftUI

struct PaymentsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {            
            Image(.sadFace)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.mainbw.opacity(0.5))
                .frame(width: 100, height: 100)
                .scaledToFit()
                .padding(.top, 50)
            
            Text("Payments are not available yet")
                .fontWeight(.semibold)
                .foregroundStyle(.mainbw.opacity(0.5))
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
    }
}

#Preview {
    PaymentsView()
}
