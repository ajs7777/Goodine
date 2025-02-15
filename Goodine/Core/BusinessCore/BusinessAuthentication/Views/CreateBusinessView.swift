//
//  CreateBusinessView.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/02/25.
//

import SwiftUI

struct CreateBusinessView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name  = ""
    @State private var type  = ""
    @State private var city = ""
    @State private var address = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    HStack{
                        Image(.businessicon)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 65, height: 80)
                        // .padding(.leading, -4)
                        
                        Spacer()
                    }
                    .padding(.top, 40)
                    
                    VStack(alignment: .leading){
                        Text("Get started with Goodine business")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Give your customers a better experience by setting up your own online store.")
                            .font(.footnote)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    //name, email, password
                    VStack(spacing: 12.0){
                        
                        TextField("Business Name", text: $name)
                            .padding(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .inset(by: 3)
                                    .stroke(style: StrokeStyle(lineWidth: 1)))
                        
                        TextField("Business Type", text: $type)
                            .padding(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .inset(by: 3)
                                    .stroke(style: StrokeStyle(lineWidth: 1)))
                        
                        TextField("Address", text: $address)
                            .padding(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .inset(by: 3)
                                    .stroke(style: StrokeStyle(lineWidth: 1)))
                        
                        TextField("City", text: $city)
                            .padding(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .inset(by: 3)
                                    .stroke(style: StrokeStyle(lineWidth: 1)))
                        
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
                                try await businessAuthVM.signUp(email: email, password: password, name: name, type: type, city: city, address: address)
                            }
                            dismiss()
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
                            .frame(width: 80, height: 32)
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
                .toolbarVisibility(.hidden, for: .navigationBar)
                .padding()
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .tint(.mainbw)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.trailing, 30)
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CreateBusinessView()
        .environmentObject(BusinessAuthViewModel())
}
