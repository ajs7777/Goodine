//
//  SettingsView.swift
//  Goodine
//
//  Created by Abhijit Saha on 03/06/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack{
                
                Button {
                    if let url = URL(string: "https://sites.google.com/view/goodine/privacy-policy") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    options(title: "Privacy Policy", image: "lock.shield")
                }
                
                Button {
                    if let url = URL(string: "https://sites.google.com/view/goodine/terms-of-use") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    options(title: "Terms of Use", image: "shield.lefthalf.filled.badge.checkmark")
                }
                
                Button {
                    if let url = URL(string: "https://sites.google.com/view/goodine/privacy-policy/account-and-data-deletion") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    options(title: "Data Deletion", image: "exclamationmark.shield")
                }
                
                Button {
                    if let url = URL(string: "https://sites.google.com/view/goodine/privacy-policy/account-and-data-deletion") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                options(title: "Account Deletion", image: "xmark.shield")
            }
                
                Spacer()
            }
            .foregroundStyle(.mainbw)
            .padding()
                .navigationTitle(Text("Settings"))
                .navigationBarTitleDisplayMode(.inline)
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
    SettingsView()
}
