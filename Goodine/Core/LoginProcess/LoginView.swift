//
//  LoginView.swift
//  Goodine
//
//  Created by Abhijit Saha on 27/01/25.
//

import SwiftUI
import Combine

struct LoginView: View {
    
    @State var phoneNumber = ""
    
    var isACtive : Bool {
        phoneNumber.count == 10 && phoneNumber.allSatisfy(\.isNumber)
    }
    
    var body: some View {
        NavigationStack {
            VStack{
                //ICON
                Image("login-icon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 400, height: 250)
                
                
                VStack(alignment: .leading){
                    Text("Get started with App")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Login or signup to use App")
                        .font(.caption)
                        .foregroundStyle(.gray)
                } .frame(maxWidth: .infinity, alignment: .leading)
                
                
                // phone number textfield
                VStack(alignment: .leading){
                    Text("Enter phone number")
                        .fontWeight(.medium)
                    HStack {
                        HStack{
                            Text("🇮🇳")
                                .font(.title)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .padding(7)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 2))
                        
                        TextField("0000000000", text: $phoneNumber)
                            .keyboardType(.numberPad)
                            .onReceive(phoneNumber.publisher.collect()) {
                                self.phoneNumber = String($0.prefix(10))
                            }

                            .padding(13)
                            .padding(.leading, 38)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .overlay(alignment: .leading) {
                                Text("+91")
                                    .padding(.leading, 15)
                                
                            }
                        
                    }
                } .padding(.vertical)
                
                Spacer()
                
                
                //another way login buttons
                HStack{
                    Button {
                        
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .font(.subheadline)
                                .tint(.mainbw)
                            Text("Login Another Way")
                                .font(.footnote)
                                .tint(.mainbw)
                                .bold()
                        }
                    }
                    
                    Text(" | ")
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Image("store")
                                .renderingMode(.template)
                                .tint(.mainbw)
                            Text("Login With Business")
                                .font(.footnote)
                                .tint(.mainbw)
                                .bold()
                        }
                    }


                }
                
                VStack(spacing: 15.0) {
                    NavigationLink {
                        VerifyDetailsView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .foregroundStyle(.mainInvert)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(!isACtive ? Color.gray : Color.mainbw)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                    }
                    .disabled(!isACtive)
                    
                    
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
                    .font(.caption)
                }
            }
            .padding()
        }
        
        
    }

    
}

#Preview {
    LoginView()
}
