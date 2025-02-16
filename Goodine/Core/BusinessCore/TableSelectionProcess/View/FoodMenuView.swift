struct FoodMenuView: View {
    let tableNumber: Int
    @State private var selectedItems: [String] = []
    
    let menuItems = ["Pizza", "Burger", "Pasta", "Salad", "Soda"]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Table \(tableNumber)")
                    .font(.title)
                    .bold()
                
                List(menuItems, id: \.self) { item in
                    HStack {
                        Text(item)
                        Spacer()
                        if selectedItems.contains(item) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .onTapGesture {
                        if selectedItems.contains(item) {
                            selectedItems.removeAll { $0 == item }
                        } else {
                            selectedItems.append(item)
                        }
                    }
                }
                
                Button("Place Order") {
                    print("Order placed: \(selectedItems) for Table \(tableNumber)")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
            }
            .navigationTitle("Order Food")
        }
    }
}
