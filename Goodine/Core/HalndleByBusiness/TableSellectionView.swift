//
//  TableSellectionView.swift
//  Goodine
//
//  Created by Abhijit Saha on 01/02/25.
//

import SwiftUI

struct TableSellectionView: View {
    var body: some View {
        NavigationStack{
            VStack {
                TableView()
                    
            }
            .navigationTitle(Text("Table Selection"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TableSellectionView()
}
