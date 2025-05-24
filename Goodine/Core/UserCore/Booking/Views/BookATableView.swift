//
//  BookATableView.swift
//  Goodine
//
//  Created by Abhijit Saha on 28/01/25.
//

import SwiftUI

struct BookATableView: View {
    let restaurantID: String
    @StateObject private var tableVM: RestaurantTableViewModel
    @State var currentTime = Date()
    @State private var showFoodMenu = false
    
    init(restaurantID: String) {
           self.restaurantID = restaurantID
           _tableVM = StateObject(wrappedValue: RestaurantTableViewModel(restaurantID: restaurantID))
       }
    
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
                    
                    datePickerView
                    
                    Divider()
                    
                    tablesGridView
                    
                    Button {
                        tableVM.saveAllSeatSelections()
                        showFoodMenu.toggle()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                            .foregroundColor(.mainInvert)
                            .frame(maxWidth: 700)
                            .frame(height: 60)
                            .background(Color.mainbw)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding()
                    .disabled(
                        !(tableVM.selectedButtons.values.contains(where: { $0.contains(true) }))
                    )

                }
            }
            .sheet(isPresented: $showFoodMenu, content: { RestaurantFoodMenuView(restaurantID: restaurantID) })
            .navigationTitle("Table Selection")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                tableVM.fetchAllSeatSelections()
            }
        }
    }
}



extension BookATableView {
        
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
