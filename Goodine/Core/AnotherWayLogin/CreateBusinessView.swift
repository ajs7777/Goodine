//
//  CreateBusinessView.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/02/25.
//

import SwiftUI

struct CreateBusinessView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var businessName = ""
    @State var businessEmail = ""
    @State var businessPassword = ""
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack{
                    Image(.businessicon)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 100)
                       // .padding(.leading, -4)
                    
                    Spacer()
                }
                .padding(.top, 40)
                
                VStack(alignment: .leading){
                    Text("Get started with Goodine business")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Give your customers a better experience by setting up your own online store.")
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                //name, email, password
                VStack(spacing: 12.0){
                    
                    TextField("Your Business Name", text: $businessName)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(style: StrokeStyle(lineWidth: 1)))
                    
                    TextField("Enter your email", text: $businessEmail)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(style: StrokeStyle(lineWidth: 1)))
                    
                    SecureField("Enter your password", text: $businessPassword)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(style: StrokeStyle(lineWidth: 1)))
                    
                    NavigationLink {
                        BusinessLoginView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        Text("Sign Up")
                            .goodineButtonStyle(.mainbw)
                    }
                    .padding(.vertical, 10)
                    
                }
                .padding(.top, 10)
                
                Spacer()
                VStack {
                    Image(.goodinetext)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 50)
                        .opacity(0.4)
                    HStack(spacing: 0.0){
                        Text("I accept the")
                        Text(" Terms & Conditions ")
                            .fontWeight(.semibold)
                            .foregroundStyle(.mainbw)
                        Text(" & ")
                        Text(" Privacy Policy")
                            .fontWeight(.semibold)
                            .foregroundStyle(.mainbw)
                    }
                    .foregroundStyle(.gray)
                    .font(.caption2)
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .tint(.mainbw)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.trailing, 6)
                    }
                }
            })
            .padding()
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CreateBusinessView()
}
