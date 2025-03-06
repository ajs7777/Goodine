//
//  LoginWithNumberView.swift
//  Goodine
//
//  Created by Abhijit Saha on 27/01/25.
//

import SwiftUI
import Combine

struct LoginWithNumberView: View {
    
//    @State var phoneNumber = ""
    
//    var isACtive : Bool {
//        phoneNumber.count == 10 && phoneNumber.allSatisfy(\.isNumber)
//    }
    
    var body: some View {
        NavigationStack {
            VStack{
                //ICON
                Image(.loginIcon)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 400, height: 250)
                
                
                VStack {
                    Text("Get started with App")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Login or signup to use App")
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
                    .padding(.bottom, 50)
                
                
                // phone number textfield
//                VStack(alignment: .leading){
//                    Text("Enter phone number")
//                        .fontWeight(.medium)
//                    HStack {
//                        HStack{
//                            Text("🇮🇳")
//                                .font(.title)
//                            Image(systemName: "chevron.down")
//                                .font(.caption)
//                        }
//                        .padding(7)
//                        .overlay(RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color.gray, lineWidth: 2))
//                        
//                        TextField("0000000000", text: $phoneNumber)
//                            .keyboardType(.numberPad)
//                            .onReceive(phoneNumber.publisher.collect()) {
//                                self.phoneNumber = String($0.prefix(10))
//                            }
//                        
//                            .padding(13)
//                            .padding(.leading, 38)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .stroke(Color.gray, lineWidth: 2)
//                            )
//                            .overlay(alignment: .leading) {
//                                Text("+91")
//                                    .padding(.leading, 15)
//                                
//                            }
//                        
//                    }
//                } .padding(.vertical)
                
//                Spacer()
                
                
                //another way login buttons
                VStack{
//                    NavigationLink {
//                        LoginWithEmail()
//                            .navigationBarBackButtonHidden()
//                    } label: {
//                        HStack {
//                            Image(systemName: "envelope.fill")
//                                .font(.subheadline)
//                            Text("Login as User")
//                                .font(.caption)
//                                .bold()
//                        } .goodineButtonStyle(.mainbw)
//                    }
                    
//                    Text("|")
//                        .font(.caption)
                    
                    NavigationLink {
                        BusinessLoginView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        HStack {
                            Image("store")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 17, height: 15)
                                
                            Text("Login With Business")
                                .font(.caption)
                                .bold()
                        }
                        .goodineButtonStyle(.mainbw)
                    }
                    
                }
                .padding(.bottom, 15)
                
                
                
                Spacer()
                VStack {
//                    NavigationLink {
//                        VerifyDetailsView()
//                            .navigationBarBackButtonHidden()
//                    } label: {
//                        Text("Continue")
//                            .goodineButtonStyle(!isACtive ? .gray : .mainbw)
//                    }
//                    .disabled(!isACtive)
                    
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
    LoginWithNumberView()
}
