//
//  LoginWithEmail.swift
//  Goodine
//
//  Created by Abhijit Saha on 31/01/25.
//

import SwiftUI

struct LoginWithEmail: View {
    
    @State var email = ""
    @State var password = ""
    @Environment(\.dismiss) var dismiss
    @State var showAnotherLogin = false

    
    var body: some View {
        NavigationStack {
            VStack{
                Image(.loginIllustration)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 260)
                
                VStack(spacing: 12.0){
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
                        MainTabView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        Text("Log In")
                            .goodineButtonStyle(.mainbw)
                    }
                    
                }
                
                HStack{
                    Button {
                        showAnotherLogin.toggle()
                    } label: {
                        Text("Create New Account")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.mainbw)
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("Forgot password?")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.mainbw)
                    }
                    
                }
                .padding(.top, 2)
                
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .tint(.mainbw)
                            .font(.title3)
                            .fontWeight(.semibold)
                            
                    }
                }
            })
            .padding()
            .onTapGesture {
                hideKeyboard()
            }
        }
        .fullScreenCover(isPresented: $showAnotherLogin, content: {
            CreateAccountView()
        })
    }
    
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginWithEmail()
}
