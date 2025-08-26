//
//  PromoCodeView.swift
//  Goodine
//
//  Created by Abhijit Saha on 03/06/25.
//

import SwiftUI

struct PromoCodeView: View {
    
    @State var promoCode = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack {
                    TextField("Enter your Code", text: $promoCode)
                        .autocapitalization(.none)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(style: StrokeStyle(lineWidth: 1)))
                    
                    Button {
                        
                    } label: {
                        Text("Redeem")
                            .fontWeight(.bold)
                            .foregroundStyle(.mainInvert)
                            .padding()
                            .background(.mainbw)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    
                }
                
                
                Image(.sadFace)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.mainbw.opacity(0.5))
                    .frame(width: 100, height: 100)
                    .scaledToFit()
                    .padding(.top, 50)
                            
                Text("No available Promocodes")
                    .fontWeight(.semibold)
                    .foregroundStyle(.mainbw.opacity(0.5))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Promocodes")
            .navigationBarTitleDisplayMode(.inline)
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
    PromoCodeView()
}
