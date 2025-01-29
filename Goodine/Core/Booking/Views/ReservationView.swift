//
//  ReservationView.swift
//  Goodine
//
//  Created by Abhijit Saha on 29/01/25.
//

import SwiftUI
import MapKit

struct ReservationView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var cameraPosition : MapCameraPosition
    @State var name = ""
    @State var email = ""
    @State var phoneNumber = ""
    @State var showConfirSheet = false
    
    init() {
        
        let region = MKCoordinateRegion(
            
            center: CLLocationCoordinate2D(latitude: 23.831457, longitude: 91.286781), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self._cameraPosition = State(initialValue: .region(region))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            //reservation text and dismiss button
            HStack {
                Text("Your Reservation")
                    .foregroundStyle(.mainbw)
                    .font(.title2)
                    .fontWeight(.bold)
                
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
            .padding(.top)
            .padding(.vertical)
            ScrollView {
                Map(position: $cameraPosition)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                //hotel details
                VStack(alignment: .leading, spacing: 5.0){
                    Text("Limelight - Royal Orchid Hotel")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Indiranagar, Bangalore, India")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
                
                Divider()
                
                //guest, date and time
                VStack(alignment: .leading, spacing: 15.0){
                    HStack(spacing: 10.0){
                        Image(systemName: "person.2")
                            .fontWeight(.semibold)
                        Text("03 Guest")
                            .font(.callout)
                    }
                    .fontWeight(.bold)
                    
                    HStack(spacing: 16.0){
                        Image(systemName: "calendar")
                            .fontWeight(.semibold)
                        Text("Tuesday | 31th Jan | 07:00 PM")
                            .font(.callout)
                    }
                    .fontWeight(.bold)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical)
                
                Divider()
                
                // name textfield
                VStack(alignment: .leading, spacing: 8.0){
                    Text("Name")
                        .fontWeight(.medium)
                    TextField( "", text: $name)
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .inset(by: 3)
                                .stroke(.gray, lineWidth: 1)
                        )
                    
                }
                .padding(.top, 12)
                
                // email text field
                VStack(alignment: .leading, spacing: 8.0){
                    Text("Email")
                        .fontWeight(.medium)
                    TextField( "", text: $email)
                        .padding(.leading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .inset(by: 3)
                                .stroke(.gray, lineWidth: 1)
                        )
                    
                }
                .padding(.top, 12)
                
                // phone number textfield
                VStack(alignment: .leading, spacing: 8.0){
                    Text("Phone Number")
                        .fontWeight(.medium)
                    TextField( "", text: $phoneNumber)
                        .padding(.leading, 85)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .inset(by: 3)
                                .stroke(.gray, lineWidth: 1)
                        )
                        .overlay(alignment: .leading) {
                            HStack{
                                Text("🇮🇳")
                                    .font(.title)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding(.leading)
                        }
                    
                }
                .padding(.top, 12)
                
                
                Button {
                    
                } label: {
                    Text("Add instructions To restaurant")
                        .font(.callout)
                        .tint(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .frame(height: 50)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.vertical, 30)
                .padding(.bottom, 100)

                
                Spacer()
                
            
            } .scrollIndicators(.hidden)
        }
        .padding(.horizontal)
        
        //confirm booking button
        
        .overlay(alignment: .bottom) {
            ZStack {
                Color.mainInvert.ignoresSafeArea()
                    .frame(height: 100)
                Button {
                    showConfirSheet.toggle()
                } label: {
                    Text("Confirm Booking")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.mainInvert)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.mainbw)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding()
                }
            }
        }
        .sheet(isPresented: $showConfirSheet, content: {
            BookingConfirmedView()
        })

    }
}

#Preview {
    ReservationView()
}
