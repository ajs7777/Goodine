//
//  BookATableView.swift
//  Goodine
//
//  Created by Abhijit Saha on 28/01/25.
//

import SwiftUI

struct BookATableView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var selectedPerson: Int? = nil
    @State var selectedDate: Int? = nil
    @State var selectedTime: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25.0) {
            
            // title and dismiss button
            HStack {
                Text("Book a table")
                    .foregroundStyle(.mainbw)
                    .font(.title)
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
            .padding()
            .padding(.top)
            
            //Tables
            VStack(alignment: .leading, spacing: 15.0){
                Text("Table for")
                    .foregroundStyle(.mainbw)
                    .font(.headline)
                ScrollView(.horizontal) {
                    HStack(spacing: 15){
                        ForEach(1...20, id: \.self){ people in
                            Text("\(people)")
                                .foregroundStyle(selectedPerson == people  ? .mainbw : .secondary)
                                .frame(width: 55, height: 40)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .inset(by: 3)
                                        .stroke(
                                            selectedPerson == people ? .mainbw : .secondary,
                                                lineWidth: selectedPerson == people ? 2 : 1)
                                       
                                }
                                .onTapGesture {
                                    selectedPerson = people
                                }
                            
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .padding(.leading)

            
            VStack(alignment: .leading, spacing: 15.0){
                Text("Date")
                    .foregroundStyle(.mainbw)
                    .font(.headline)
                ScrollView(.horizontal) {
                    HStack(spacing: 12){
                        ForEach(1...31, id: \.self){ date in
                            VStack{
                                Text("Today")
                                
                                    .font(.footnote)
                                Text("\(date) Jan")
                            }
                            .foregroundStyle(selectedDate == date  ? .mainbw : .secondary)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .inset(by: 3)
                                        .stroke(
                                            selectedDate == date ? .mainbw : .secondary,
                                                lineWidth: selectedDate == date ? 2 : 1)
                                       
                                }
                                .onTapGesture {
                                    selectedDate = date
                                }
                        }
                    }
                } .scrollIndicators(.hidden)
            }
            .padding(.leading)
            
            VStack(alignment: .leading, spacing: 15.0){
                Text("Time")
                    .foregroundStyle(.mainbw)
                    .font(.headline)
              VStack(spacing: 20.0){
                    ForEach(1..<5) { row in
                        HStack(spacing: 20.0){
                            ForEach(1...3, id: \.self){ time in
                                Text("07 : 00 PM")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(selectedTime == row ? .mainbw : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(
                                                selectedTime == row ? .mainbw : .secondary,
                                                    lineWidth: selectedTime == row ? 2 : 1)
                                           
                                    }
                                    .onTapGesture {
                                        selectedTime = row
                                    }
                            }
                        }
                    }
                }
                    
                
            }
            .padding()

            
            Spacer()
            
            Button {
               
            } label: {
                Text("Next")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.mainInvert)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.mainbw)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding()
            }
        }
    }
}

#Preview {
    BookATableView()
}
