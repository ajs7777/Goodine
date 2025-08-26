import SwiftUI

struct VerifyEmailView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    let email: String
    let password: String

    @State private var verificationComplete = false
    @State private var showTick = false
    @State private var timedOut = false

    var body: some View {
        VStack(spacing: 24) {
            if showTick {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                    .scaleEffect(verificationComplete ? 1.0 : 0.5)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: verificationComplete)

                Text("Email Verified!")
                    .font(.title2)
                    .fontWeight(.semibold)
            } else {
                Image(systemName: "envelope.badge")
                    .font(.system(size: 60))
                    .foregroundColor(.mainbw)

                Text("We've sent a verification email.")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text("Please check your inbox and verify your email address.")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)

                if timedOut {
                    Text("⏳ Timed out waiting for verification.")
                }

                ProgressView()
            }
        }
        .padding()
        .task {
            let verified = await viewModel.waitForEmailVerification(email: email, password: password)

            if verified {
                verificationComplete = true
                showTick = true

                // Wait briefly to let animation show
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                // Optionally wait longer for smoother feel
                try? await Task.sleep(nanoseconds: 500_000_000)

                dismiss() // or navigate to main app screen
            } else {
                timedOut = true
            }
        }
    }
}
