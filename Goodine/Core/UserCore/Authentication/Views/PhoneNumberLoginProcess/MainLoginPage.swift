//
//  MainLoginPage.swift
//  Goodine
//
//  Created by Abhijit Saha on 27/01/25.
//

import SwiftUI
import Combine

struct MainLoginPage: View {

    
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

                VStack{
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
                        .padding(.horizontal)
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
    MainLoginPage()
}
