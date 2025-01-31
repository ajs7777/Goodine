//
//  BookingConfirmedView.swift
//  Goodine
//
//  Created by Abhijit Saha on 29/01/25.
//

import SwiftUI

struct BookingConfirmedView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Close Button
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.mainbw)
                        .fontWeight(.bold)
                        .padding(.trailing)
                }
            }
            
            // Confirmation icon
            
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .foregroundStyle(.green)
            
            
            // Title
            Text("Booking Confirmed!!")
                .font(.title)
                .fontWeight(.heavy)
            
            // Booking ID
            VStack(alignment: .leading) {
                Text("Booking ID")
                    .font(.body)
                    .fontWeight(.bold)
           
            Text("#10033784784974")
                .foregroundColor(.gray)
                .font(.caption)
            } .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            // Hotel Information
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Limelight - Royal Orchid Hotel")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Indiranagar, Bengaluru, India")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
                
                Spacer()
                
                Image(systemName: "phone")
                    .fontWeight(.semibold)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.vertical, 5)
            
            
            // Guest and Date Information
            VStack(spacing: 20.0) {
                HStack {
                    Image(systemName: "person.2")
                        .fontWeight(.bold)
                    Text("03 Guest")
                        .font(.headline)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(" Tuesday | 31 Jan | 07:00 PM")
                        .fontWeight(.medium)
                        .font(.headline)
                    Spacer()
                }
                
            } .padding(.top)

            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 10) {
                Button(action: {
                    // Add modify booking action
                }) {
                    Text("Modify Booking")
                        .font(.headline)
                        .font(.title3)
                        .goodineButtonStyle(.mainbw)
                }
                
                Button(action: {
                    // Add cancel booking action
                }) {
                    Text("Cancel Booking")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .foregroundColor(.mainbw)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.top, 20)
        .padding()
    }
}

#Preview {
    BookingConfirmedView()
}
