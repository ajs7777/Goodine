//
//  VerifyDetailsView.swift
//  Goodine
//
//  Created by Abhijit Saha on 27/01/25.
//

import SwiftUI

struct VerifyDetailsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var otp = ["", "", "", "", "", ""]
    @State private var timerRemaining = 30
    @State private var isTimerActive = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Navigation Back Button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            
            // Title and description
            VStack(alignment: .leading, spacing: 8) {
                Text("Verify your details")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack(spacing: 0.0) {
                    Text("Enter OTP sent to ")
                    Text("+91 9860310313")
                        .foregroundStyle(.black)
                        .fontWeight(.medium)
                    Text(" via SMS")
                        
                }
                .font(.footnote)
                .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // OTP Entry Fields
            HStack(spacing: 20) {
                ForEach(0..<4, id: \.self) { index in
                    TextField("", text: $otp[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .onReceive(otp[index].publisher.collect()) { value in
                            if value.count > 1 {
                                otp[index] = String(value.first ?? Character(""))
                            }
                        }
                }
                Spacer()
            }
            
            // Resend and Timer
            HStack {
                Text("Didn't receive OTP?")
                    .foregroundColor(.gray)
                
                Button(action: {
                    // Handle resend action
                    resendOTP()
                }) {
                    Text("Resend")
                        .foregroundColor(isTimerActive ? .gray : .green)
                }
                .disabled(isTimerActive)
                
                
                Spacer()
                
                Text("00:\(String(format: "%02d", timerRemaining))")
                    .foregroundColor(.gray)
                    
                Spacer()

                Spacer()

            }
            .font(.footnote)
            
            Spacer()
            
            // Verify Button
            NavigationLink {
                MainTabView()
                    .navigationBarBackButtonHidden()
            } label: {
                Text("Verify & continue")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.bottom)
        }
        .padding(.top)
        .padding(.horizontal)
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timerRemaining > 0 {
                timerRemaining -= 1
            } else {
                isTimerActive = false
                timer.invalidate()
            }
        }
    }
    
    func resendOTP() {
        timerRemaining = 30
        isTimerActive = true
        startTimer()
        // Add resend logic
    }
}

#Preview {
    VerifyDetailsView()
}
