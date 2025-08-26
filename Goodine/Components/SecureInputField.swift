//
//  SecureInputField.swift
//  Goodine
//
//  Created by Abhijit Saha on 05/06/25.
//


import SwiftUI

struct SecureInputField: View {
    var placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true

    var body: some View {
        HStack {
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .autocapitalization(.none)

            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
        
    }
}
