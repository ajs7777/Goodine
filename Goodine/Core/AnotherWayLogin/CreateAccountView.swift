//
//  CreateAccountView.swift
//  Goodine
//
//  Created by Abhijit Saha on 31/01/25.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var name = ""
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        NavigationStack {
            VStack{
                HStack{
                    Image(.goodinetext)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 30)
                        .padding(.leading, -4)
                    
                    Spacer()
                }
                .padding(.top, 60)
                
                VStack(alignment: .leading){
                    Text("Get started on Goodine")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Create an accaount to get the best dine in experice, Like never before.")
                        .font(.footnote)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                //name, email, password
                VStack(spacing: 12.0){
                    
                    TextField("Name", text: $name)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(style: StrokeStyle(lineWidth: 1)))
                    
                    TextField("Enter your email", text: $email)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(style: StrokeStyle(lineWidth: 1)))
                    
                    SecureField("Enter your password", text: $password)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(style: StrokeStyle(lineWidth: 1)))
                    
                    NavigationLink {
                        LoginWithEmail()
                            .navigationBarBackButtonHidden()
                    } label: {
                        Text("Sign Up")
                            .goodineButtonStyle(.mainbw)
                    }
                    .padding(.vertical)
                    
                }
                .padding(.top, 20)
                
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
    CreateAccountView()
}
