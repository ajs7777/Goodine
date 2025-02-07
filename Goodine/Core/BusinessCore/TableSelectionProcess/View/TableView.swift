//
//  TableView.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/02/25.
//

import SwiftUI

struct TableView: View {
    
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var rows: Int = 4
    @State private var columns: Int = 2
    
    @State private var selectedButtons: [[Bool]] = Array(repeating: Array(repeating: false, count: 4), count: 100)
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    @State var showTableEditor = false
    
    @State var currentTime = Date()
    
    var timeFormatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
    var dateFormatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    
    var body: some View {
        NavigationStack{
        VStack {
            // Controls for selecting rows and columns
            
            if showTableEditor{
                HStack {
                    Image(systemName: "text.badge.plus")
                        .fontWeight(.bold)
                        .foregroundStyle(.mainbw.opacity(0.5))
                        .scaleEffect(x: -1, y: 1)
                    
                    //Text("\(rows)")
                            Stepper("", value: Binding(
                                get: { rows },
                                set: { rows = max(1, min($0, 10)) } // Ensures value stays in range
                            ))
                            .labelsHidden()
                    
                  //  Spacer()
                        //    Text("Columns: \(columns)")
                    Image(systemName: "text.badge.plus")
                        .fontWeight(.bold)
                        .foregroundStyle(.mainbw.opacity(0.5))
                        .scaleEffect(x: 1, y: -1)
                        .rotationEffect(.degrees(270))
                    
                            Stepper("", value: Binding(
                                get: { columns },
                                set: { columns = max(1, min($0, 8)) }
                            )).labelsHidden()
                    Spacer()
                    
                    Button{
                        withAnimation(.spring(duration: 0.2)){
                            showTableEditor.toggle()
                        }
                    }label: {
                        Text("Done")
                            .fontWeight(.semibold)
                            .foregroundStyle(.mainbw)
                            .padding(.trailing)
                    }
                }
                .padding()
            } else {
                HStack{
                    VStack(alignment: .leading) {
                        Text (dateFormatter.string(from: currentTime))
                            .foregroundStyle(.orange)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text (timeFormatter.string(from: currentTime))
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Button{
                        withAnimation(.spring(duration: 0.2)){
                            showTableEditor.toggle()
                        }
                    }label: {
                        HStack{
                            Image(systemName: "plus")
                            Text("Add Table")
                        }
                        .bold()
                        .foregroundStyle(.mainInvert)
                        .padding(9)
                        .background(.mainbw)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                }
                .padding(.horizontal)
                .onReceive(timer) { value in
                    currentTime = value
                }
                    
            }
            
            
            
            Divider()
            
            // Dynamic grid
            GeometryReader { geometry in
                let squareSize = min(geometry.size.width / CGFloat(columns),
                                     geometry.size.height / CGFloat(rows))
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 30), count: columns), spacing: 15) {
                    ForEach(1...(rows * columns), id: \.self) { index in
                        SquareView(size: squareSize, buttonStates: $selectedButtons[index], tableCount: index)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
               // .frame(height: UIScreen.main.bounds.height / 2)
            }
            .padding()
            .padding(.horizontal)
            .padding(.vertical, 50)
            
            Button{
               
            }label: {
                Text("Done")
                    .goodineButtonStyle(.mainbw)
            }.padding()
        }
        }
        .navigationTitle(Text("Table Selection"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SquareView: View {
    let size: CGFloat
    @Binding var buttonStates: [Bool]
    let tableCount: Int
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.mainbw.opacity(0.1))
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Text("\(tableCount)")
                .font(.caption)
                .bold()
                .foregroundStyle(.mainbw.opacity(0.5))
            
            let smallSize = size * 0.35 // Each small rectangle is 20% of the main square's width and height
            
            VStack(spacing: size * 0.1) {
                HStack(spacing: size * 0.1) {
                    SmallButton(isActive: $buttonStates[0], size: smallSize)
                    SmallButton(isActive: $buttonStates[1], size: smallSize)
                }
                HStack(spacing: size * 0.1) {
                    SmallButton(isActive: $buttonStates[2], size: smallSize)
                    SmallButton(isActive: $buttonStates[3], size: smallSize)
                }
            }
        }
    }
}

// Small Button (20% of big square)
struct SmallButton: View {
    @Binding var isActive: Bool
    let size: CGFloat
    
    var body: some View {
        Button(action: { isActive.toggle() }) {
            Rectangle()
                .fill(isActive ? Color.green : Color.mainbw.opacity(0.2))
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
#Preview {
    TableView()
}
