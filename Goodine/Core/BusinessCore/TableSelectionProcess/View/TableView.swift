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
    @State var currentTime = Date()
    @State private var showTableEditor = false
    @State private var showFoodMenu = false  // (This flag can be used to present a food menu view if needed)
    
    // Timer for updating the current time every second.
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    // Date & Time Formatters
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                
                // Display error if any.
                if let errorMessage = tableVM.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                if tableVM.isLoading {
                    ProgressView("Loading tables...")
                        .padding()
                } else {
                    if showTableEditor {
                        tableEditorView
                    } else {
                        datePickerView
                    }
                    
                    Divider()
                    
                    tablesGridView
                    
                    Button {
                        tableVM.saveAllSeatSelections()
                    } label: {
                        Text("Done")
                            .goodineButtonStyle(.mainbw)
                    }
                    .padding()
                }
            }
            .navigationTitle("Table Selection")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                tableVM.fetchAllSeatSelections()
            }
        }
    }
}

// MARK: - Subviews

extension TableView {
    
    // MARK: Table Editor View
    private var tableEditorView: some View {
        HStack {
            Image(systemName: "text.badge.plus")
                .font(.title2)
                .foregroundStyle(Color.primary.opacity(0.5))
                .scaleEffect(x: -1, y: 1)
            
            // Rows stepper
            Stepper(value: Binding(
                get: { tableVM.rows },
                set: { tableVM.rows = max(1, min($0, 10)) }
            )) {
                Text("Rows: \(tableVM.rows)")
            }
            .labelsHidden()
            
            Image(systemName: "text.badge.plus")
                .font(.title2)
                .foregroundStyle(Color.primary.opacity(0.5))
                .scaleEffect(x: 1, y: -1)
                .rotationEffect(.degrees(270))
            
            // Columns stepper
            Stepper(value: Binding(
                get: { tableVM.columns },
                set: { tableVM.columns = max(1, min($0, 8)) }
            )) {
                Text("Columns: \(tableVM.columns)")
            }
            .labelsHidden()
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.2)) {
                    tableVM.saveTableLayout()
                    showTableEditor.toggle()
                }
            } label: {
                Text("Done")
                    .foregroundStyle(.mainbw)
                    .fontWeight(.semibold)
                    .padding(.trailing)
            }
        }
        .padding()
    }
    
    // MARK: Date & Time Picker View
    private var datePickerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dateFormatter.string(from: currentTime))
                    .foregroundColor(.orange)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(timeFormatter.string(from: currentTime))
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.2)) {
                    showTableEditor.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Table")
                }
                .bold()
                .padding(9)
                .background(Color.mainbw)
                .foregroundColor(.mainInvert)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal)
        .onReceive(timer) { value in
            currentTime = value
        }
    }
    
    // MARK: Tables Grid View
    private var tablesGridView: some View {
        GeometryReader { geometry in
            // Ensure we have valid numbers of rows and columns.
            let safeColumns = max(1, tableVM.columns)
            let safeRows = max(1, tableVM.rows)
            
            // Calculate each cell's available width and height.
            let cellWidth = geometry.size.width / CGFloat(safeColumns)
            let cellHeight = geometry.size.height / CGFloat(safeRows)
            
            // Subtract a fixed padding (20) and ensure the value doesn't drop below a minimum size.
            let squareSize = max(30, min(cellWidth, cellHeight) - 20)
            
            // Debug: Uncomment the next line to see the sizes.
            // print("geometry: \(geometry.size), cellWidth: \(cellWidth), cellHeight: \(cellHeight), squareSize: \(squareSize)")
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: safeColumns), spacing: 15) {
                    ForEach(1...(safeRows * safeColumns), id: \.self) { tableIndex in
                        // Create a binding for the table's seat states.
                        let seatBinding = Binding<[Bool]>(
                            get: { tableVM.selectedButtons[tableIndex] ?? Array(repeating: false, count: 4) },
                            set: { tableVM.selectedButtons[tableIndex] = $0 }
                        )
                        
                        TableCellView(
                            tableIndex: tableIndex,
                            seatStates: seatBinding,
                            tablePeopleCount: $tableVM.tablePeopleCount,
                            reservedSeats: tableVM.reservedSeats[tableIndex] ?? Array(repeating: false, count: 4),
                            selectedTable: $tableVM.selectedTable,
                            cellSize: squareSize
                        )
                    }
                }
                .padding()
            }
        }
        .frame(minHeight: 300)
        // Ensure GeometryReader gets a non-zero size.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

// MARK: - Table Cell View

struct TableCellView: View {
    let tableIndex: Int
    @Binding var seatStates: [Bool]
    @Binding var tablePeopleCount: [Int: Int]
    let reservedSeats: [Bool]
    @Binding var selectedTable: Int?
    let cellSize: CGFloat
    
    var body: some View {
        ZStack {
            // Background for table cell
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
                .frame(width: cellSize, height: cellSize)
                .onTapGesture {
                    selectedTable = tableIndex
                }
            
            
                Text("\(tableIndex)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Grid for 4 seats (2 rows x 2 columns)
                let seatButtonSize = cellSize * 0.35
                VStack(spacing: cellSize * 0.1) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: cellSize * 0.1) {
                            ForEach(0..<2, id: \.self) { col in
                                let seatIndex = row * 2 + col
                                SmallSeatButton(
                                    isSelected: Binding(
                                        get: { seatStates[seatIndex] },
                                        set: { newValue in
                                            seatStates[seatIndex] = newValue
                                            // Update people count accordingly.
                                            let currentCount = tablePeopleCount[tableIndex] ?? 0
                                            tablePeopleCount[tableIndex] = newValue ? currentCount + 1 : max(currentCount - 1, 0)
                                            if tablePeopleCount[tableIndex] == 0 {
                                                tablePeopleCount.removeValue(forKey: tableIndex)
                                            }
                                        }
                                    ),
                                    isReserved: reservedSeats[safe: seatIndex] ?? false,
                                    size: seatButtonSize
                                )
                            }
                        }
                    }
                }
            
        }
    }
}

// MARK: - Small Seat Button View

struct SmallSeatButton: View {
    @Binding var isSelected: Bool
    let isReserved: Bool
    let size: CGFloat
    
    var body: some View {
        Button {
            // Only allow toggle if not reserved.
            guard !isReserved else { return }
            isSelected.toggle()
        } label: {
            let safeSize = max(10, size)
            RoundedRectangle(cornerRadius: 10)
                .fill(isReserved ? Color.orange.opacity(0.6) : (isSelected ? Color.green : Color.gray.opacity(0.3)))
                .frame(width: safeSize, height: safeSize)
                .overlay(
                    isReserved ? Image(systemName: "person.fill").foregroundColor(.white) : nil
                )
        }
        .disabled(isReserved)
    }
}

// MARK: - Array Safe Indexing Extension

extension Array {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview {
    TableView()    
}

