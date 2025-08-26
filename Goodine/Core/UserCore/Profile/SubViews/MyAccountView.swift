//
//  MyAccountView.swift
//  Goodine
//
//  Created by Abhijit Saha on 03/06/25.
//

import SwiftUI

struct MyAccountView: View {
    
    @State var name = ""
    @State var phoneNumber = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM : AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Text("Name")
                        .fontWeight(.semibold)
                    VStack {
                        TextField("Name", text: $name)
                            .textContentType(.name)
                        Divider()
                    }
                }
                
                HStack {
                    Text("Phone Number")
                        .fontWeight(.semibold)
                    VStack {
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                        Divider()
                    }
                }
                
                Spacer()
                
                Button {
                    Task {
                        await authVM.updateUserData(fullName: name, phoneNumber: phoneNumber)
                        dismiss()
                    }
                } label: {
                    Text("Done")
                }
                .goodineButtonStyle(.mainbw)
                
            }
            .foregroundStyle(.mainbw)
            .padding()
            .navigationTitle("My Account")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let user = authVM.userdata {
                    name = user.fullName
                    phoneNumber = user.phoneNumber
                }
            }
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
    MyAccountView()
}
