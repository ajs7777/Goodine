
import SwiftUI

import Foundation

enum PaymentApp: String, CaseIterable, Identifiable {
    case googlePay = "Google Pay"
    case phonePe = "PhonePe"
    case paytm = "Paytm"
    case any = "Any UPI App"
    
    var id: String { rawValue }
    
    var schemePrefix: String {
        switch self {
        case .googlePay: return "tez"
        case .phonePe: return "phonepe"
        case .paytm: return "paytmmp"
        case .any: return "upi"
        }
    }
    
    var logoName: String {
        switch self {
        case .googlePay: return "gpay_logo"
        case .phonePe: return "phonepe_logo"
        case .paytm: return "paytm_logo"
        case .any: return "upi_generic"
        }
    }
}


struct PaymentSelectionSheet: View {
    
    @Binding var isPresented: Bool
    @AppStorage("selectedPaymentApp") private var selectedAppRaw: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(PaymentApp.allCases) { app in
                        let isSelected = selectedAppRaw == app.rawValue

                        PaymentOptionRow(app: app, isSelected: isSelected)
                            .onTapGesture {
                                selectedAppRaw = app.rawValue
                            }
                    }


                }
                .listStyle(.insetGrouped)
                
                Spacer()
                
                Button("Done") {
                    isPresented = false
                }
                .goodineButtonStyle(.mainbw)
                .padding(.horizontal)
            }
            .navigationTitle("Select Payment Method")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PaymentOptionRow: View {
    let app: PaymentApp
    let isSelected: Bool

    var body: some View {
        HStack {
            Image(app.logoName)
                .resizable()
                .frame(width: 40, height: 40)
                .cornerRadius(6)
                .padding(.trailing, 5)

            Text(app.rawValue)
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .orange : .gray)
                .font(.headline)
        }
        .contentShape(Rectangle())
    }
}

