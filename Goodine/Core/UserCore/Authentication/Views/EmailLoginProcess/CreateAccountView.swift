//
//  CreateAccountView.swift
//  Goodine
//
//  Created by Abhijit Saha on 31/01/25.
//

import SwiftUI
import PhoneNumberKit
import FirebaseAuth

struct CreateAccountView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var fullName = ""
    @State var email = ""
    @State var password = ""
    @State var phoneNumber = ""
    @State var phoneNumberValid: Bool = true
    @State private var showVerificationAlert = false
    @State private var showVerifyEmailView = false
    @State private var emailTakenError = ""

    private let phoneNumberKit = PhoneNumberUtility()

    @EnvironmentObject var viewModel : AuthViewModel
   
    
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
                    
                    TextField("Name", text: $fullName)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(style: StrokeStyle(lineWidth: 1))
                        )
                                            
                    TextField("Phone Number", text: $phoneNumber)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(phoneNumberValid ? Color.gray : Color.red, lineWidth: 1)
                        )
                        .keyboardType(.phonePad)
                        .onChange(of: phoneNumber) {
                            formatAndValidatePhoneNumber(phoneNumber)
                        }
                    
                    TextField("Enter your email", text: $email)
                        .autocapitalization(.none)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(style: StrokeStyle(lineWidth: 1)))
                    
                    SecureInputField(placeholder: "Enter your password", text: $password)
                        .padding(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .inset(by: 3)
                                .stroke(style: StrokeStyle(lineWidth: 1)))
                    
                    if !emailTakenError.isEmpty {
                        Text(emailTakenError)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.leading, 4)
                    }
                    
                    Button {
                        Task {
                            emailTakenError = ""
                            do {
                                try await viewModel.createUser(
                                    email: email,
                                    password: password,
                                    fullName: fullName,
                                    phoneNumber: phoneNumber
                                )
                                showVerifyEmailView = true
                            } catch {
                                if let err = error as NSError?,
                                   err.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                                    emailTakenError = "This email is already registered."
                                } else {
                                    print("Unhandled error: \(error.localizedDescription)")
                                }
                            }
                        }
                    } label: {
                        Text("Sign Up")
                            .goodineButtonStyle(.mainbw)
                    }

                    .padding(.vertical)
                    .disabled(!phoneNumberValid)
                    .fullScreenCover(isPresented: $showVerifyEmailView) {
                        VerifyEmailView(email: email, password: password)
                    }
                    .alert("Verify Your Email", isPresented: $showVerificationAlert) {
                        Button("OK") {
                            dismiss()
                        }
                    } message: {
                        Text("A verification email has been sent to \(email). Please verify before logging in.")
                    }

                    
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
            .frame(maxWidth: 500)
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
    
    func formatAndValidatePhoneNumber(_ number: String) {
        do {
            let parsedNumber = try phoneNumberKit.parse(number)
            // Format number to international format, which includes +countryCode
            let formattedNumber = phoneNumberKit.format(parsedNumber, toType: .international)
            
            // Update the phone number with formatted value only if different to avoid infinite loop
            if formattedNumber != phoneNumber {
                phoneNumber = formattedNumber
            }
            
            phoneNumberValid = true
        } catch {
            phoneNumberValid = false
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func flagEmoji(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flagString = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let scalarValue = UnicodeScalar(base + scalar.value) {
                flagString.unicodeScalars.append(scalarValue)
            }
        }
        return flagString
    }

}

#Preview {
    CreateAccountView()
}
