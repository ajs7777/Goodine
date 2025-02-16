//
//  TableView.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/02/25.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct TableView: View {
    
    @StateObject var tableVM = TableViewModel()
        
    @State var showTableEditor = false
    @State private var showFoodMenu = false
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
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
        NavigationStack {
            VStack {
                if tableVM.isLoading {
                    ProgressView("Loading tables...")
                        .padding()
                } else {
                    if showTableEditor {
                        AddTableView
                    } else {
                        DatePickerView
                    }
                    
                    Divider()
                    
                    TablesView
                    
                    Button {
                        tableVM.saveAllSeatSelections()
                    } label: {
                        Text("Done")
                            .goodineButtonStyle(.mainbw)
                    }
                    .padding()
                    
                    VStack {
                        Text("People Count Per Table:")
                            .font(.headline)
                            .bold()
                        ForEach(tableVM.tablePeopleCount.sorted(by: { $0.key < $1.key }), id: \.key) { table, count in
                            Text("Table \(table): \(count) people")
                                .font(.subheadline)
                                .foregroundStyle(.mainbw)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(Text("Table Selection"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                tableVM.fetchTableLayout()
                tableVM.fetchAllSeatSelections()
            }
            
        }
    }
    
}

#Preview {
    TableView()
}

extension TableView {
    
    private var AddTableView: some View {
        HStack {
            Image(systemName: "text.badge.plus")
                .fontWeight(.bold)
                .foregroundStyle(.mainbw.opacity(0.5))
                .scaleEffect(x: -1, y: 1)
            
            Stepper("", value: Binding(
                get: { tableVM.rows },
                set: { tableVM.rows = max(1, min($0, 10)) }
            ))
            .labelsHidden()
            
            Image(systemName: "text.badge.plus")
                .fontWeight(.bold)
                .foregroundStyle(.mainbw.opacity(0.5))
                .scaleEffect(x: 1, y: -1)
                .rotationEffect(.degrees(270))
            
            Stepper("", value: Binding(
                get: { tableVM.columns },
                set: { tableVM.columns = max(1, min($0, 8)) }
            )).labelsHidden()
            
            Spacer()
            
            Button {
                withAnimation(.spring(duration: 0.2)) {
                    tableVM.saveTableLayout()
                    showTableEditor.toggle()
                }
            } label: {
                Text("Done")
                    .fontWeight(.semibold)
                    .foregroundStyle(.mainbw)
                    .padding(.trailing)
            }
        }
        .padding()
    }
    
    private var DatePickerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dateFormatter.string(from: tableVM.currentTime))
                    .foregroundStyle(.orange)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(timeFormatter.string(from: tableVM.currentTime))
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(duration: 0.2)) {
                    showTableEditor.toggle()
                }
            } label: {
                HStack {
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
            tableVM.currentTime = value
        }
    }
    
    private var TablesView: some View {
        GeometryReader { geometry in
            let squareSize = min(geometry.size.width / CGFloat(tableVM.columns),
                                 geometry.size.height / CGFloat(tableVM.rows))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 30), count: tableVM.columns), spacing: 15) {
                ForEach(1...(tableVM.rows * tableVM.columns), id: \.self) { index in
                    squareView(size: squareSize,
                               buttonStates: $tableVM.selectedButtons[index],
                               tableCount: index,
                               showFoodMenu: $showFoodMenu,
                               selectedTable: $tableVM.selectedTable,
                               tablePeopleCount: $tableVM.tablePeopleCount
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .padding()
        .padding(.horizontal)
        .padding(.vertical, 50)
    }
    
    func squareView(size: CGFloat, buttonStates: Binding<[Bool]>, tableCount: Int, showFoodMenu: Binding<Bool>, selectedTable: Binding<Int?>, tablePeopleCount: Binding<[Int: Int]>) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.mainbw.opacity(0.1))
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onTapGesture {
                    selectedTable.wrappedValue = tableCount
                }
            
            Text("\(tableCount)")
                .font(.caption)
                .bold()
                .foregroundStyle(.mainbw.opacity(0.5))
            
            let smallSize = size * 0.35
            
            VStack(spacing: size * 0.1) {
                ForEach(0..<2, id: \.self) { row in
                    HStack(spacing: size * 0.1) {
                        ForEach(0..<2, id: \.self) { col in
                            let index = row * 2 + col
                            smallButton(
                                isSelected: buttonStates[index],
                                size: smallSize,
                                tableCount: tableCount,
                                seatIndex: index,
                                tablePeopleCount: tablePeopleCount
                            )
                        }
                    }
                }
            }
        }
        .onAppear {
            print("Rendering Table \(tableCount) - Seats: \(buttonStates.wrappedValue)")
        }
    }
    
    func smallButton(isSelected: Binding<Bool>, size: CGFloat, tableCount: Int, seatIndex: Int, tablePeopleCount: Binding<[Int: Int]>) -> some View {
        let isReserved = tableVM.reservedSeats[tableCount]?[seatIndex] ?? false  // Check if the seat is reserved
        
        return Button(action: {
            guard !isReserved else { return }
            
            isSelected.wrappedValue.toggle()
            
            tablePeopleCount.wrappedValue[tableCount, default: 0] += isSelected.wrappedValue ? 1 : -1
            if tablePeopleCount.wrappedValue[tableCount] == 0 {
                tablePeopleCount.wrappedValue.removeValue(forKey: tableCount)
            }
            
            print("Table \(tableCount): \(tablePeopleCount.wrappedValue[tableCount] ?? 0) people")
            
        }) {
            Rectangle()
                .fill(isReserved ? Color.red.opacity(0.6) : (isSelected.wrappedValue ? Color.green : Color.gray.opacity(0.3)))
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    isReserved ? Image(systemName: "lock.fill").foregroundColor(.white) : nil
                )
        }
        .disabled(isReserved)
    }
    
}
