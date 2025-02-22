struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var foodname: String = ""
    @State private var foodDescription: String = ""
    @State private var foodPrice: String = ""
    @State private var foodQuantity: String = ""
    @State private var foodImage: String = ""
    @State private var veg: Bool = false
    
    var onSave: (MenuItem) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Food Name", text: $foodname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Description", text: $foodDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Price", text: $foodPrice)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            TextField("Quantity", text: $foodQuantity)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
            
            TextField("Image URL", text: $foodImage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Toggle("Vegetarian", isOn: $veg)
            
            Button("Done") {
                if let priceValue = Int(foodPrice), let quantityValue = Int(foodQuantity) {
                    let newItem = MenuItem(id: UUID().uuidString, foodname: foodname, foodDescription: foodDescription, foodPrice: priceValue, foodQuantity: quantityValue, foodImage: foodImage, veg: veg)
                    onSave(newItem)
                    dismiss()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .presentationDetents([.medium])
    }
}