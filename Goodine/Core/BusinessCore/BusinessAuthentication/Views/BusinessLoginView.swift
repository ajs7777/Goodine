//
//  BusinessLoginView.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/02/25.
//

import SwiftUI

struct BusinessLoginView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var showBusinessLogin = false
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack{
                Image(.businessicon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 280)
                
                VStack(spacing: 12.0){
                    TextField("Enter your email", text: $email)
                        .autocapitalization(.none)
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
                    
                    Button {
                        Task{
                           try await businessAuthVM.signIn(email: email, password: password)
                        }
                    } label: {
                        Text("Log In")
                            .goodineButtonStyle(.mainbw)
                    }
                    
                }
                
                HStack{
                    Button {
                        showBusinessLogin.toggle()
                    } label: {
                        Text("Create Business Account")
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
                        Text("By clicking, I accept the")
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
        .fullScreenCover(isPresented: $showBusinessLogin, content: {
            CreateBusinessView()
        })
    }
    
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    BusinessLoginView()
}
