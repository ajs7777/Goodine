//
//  LoginWithEmail.swift
//  Goodine
//
//  Created by Abhijit Saha on 31/01/25.
//

import SwiftUI
import FirebaseAuth

struct LoginWithEmail: View {
    
    @State var email = ""
    @State var password = ""
    @Environment(\.dismiss) var dismiss
    @State var showAnotherLogin = false
    @State private var resetEmailSent = false
    @State private var showResetAlert = false
    @State private var showEmailNotVerifiedAlert = false
    @State private var showResentConfirmation = false
    
    @State private var loginErrorMessage = ""


    @EnvironmentObject var viewModel : AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack{
                Image(.loginIllustration)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 260)
                
                
                VStack(spacing: 12.0){
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
                    
                    if !loginErrorMessage.isEmpty {
                        Text(loginErrorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    
                    Button {
                        Task {
                            do {
                                try await viewModel.signIn(email: email, password: password)
                                loginErrorMessage = ""
                            } catch {
                                let nsError = error as NSError
                                if nsError.localizedDescription.contains("Email not verified") {
                                    showEmailNotVerifiedAlert = true
                                } else {
                                    loginErrorMessage = friendlyAuthError(from: error)
                                }
                            }

                        }
                    } label: {
                        Text("Log In")
                            .goodineButtonStyle(.mainbw)
                    }
                    .alert("Email Not Verified", isPresented: $showEmailNotVerifiedAlert) {
                        Button("Resend Email") {
                            Task {
                                do {
                                    try await Auth.auth().signIn(withEmail: email, password: password) // needed to access currentUser
                                    try await viewModel.resendVerificationEmail()
                                    try? Auth.auth().signOut()
                                    showResentConfirmation = true
                                } catch {
                                    print("Resend failed")
                                }
                            }
                        }
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Please verify your email before logging in.")
                    }
                    .alert("Verification Email Sent", isPresented: $showResentConfirmation) {
                        Button("OK", role: .cancel) { }
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
                        Task {
                            await viewModel.resetPassword(email: email)
                            resetEmailSent = true
                            showResetAlert = true
                        }
                    } label: {
                        Text("Forgot password?")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.mainbw)
                    }
                    .disabled(email.isEmpty)

                    
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
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text(resetEmailSent ? "Reset Email Sent" : "Error"),
                    message: Text(resetEmailSent ? "Check your inbox for password reset instructions." : "Please enter a valid email address."),
                    dismissButton: .default(Text("OK"))
                )
            }

            .frame(maxWidth: 500)
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
    
    private func friendlyAuthError(from error: Error) -> String {
        let code = (error as NSError).code

        switch code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        case AuthErrorCode.invalidEmail.rawValue:
            return "The email address is not valid."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email."
        case AuthErrorCode.userDisabled.rawValue:
            return "This account has been disabled."
        case AuthErrorCode.invalidCredential.rawValue:
            return "Something went wrong. Please try again."
        default:
            return "Login failed. Please check your credentials and try again."
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginWithEmail()
}
