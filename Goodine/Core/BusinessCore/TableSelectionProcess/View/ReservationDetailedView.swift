//
//  ReservationDetailedView.swift
//  Goodine
//
//  Created by Abhijit Saha on 27/02/25.
//

import SwiftUI
import PDFKit

struct ReservationDetailedView: View {
    
    @ObservedObject var orderVM = OrdersViewModel()
    @ObservedObject var tableVM = TableViewModel()
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel    
    
    let reservationId: String
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    // Calculate total order price
    private var totalPrice: Double {
        orderVM.orders.reduce(0) { total, order in
            total + order.items.values.reduce(0) { subtotal, item in
                subtotal + (item.price * Double(item.quantity))
            }
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            if let reservation = tableVM.reservations.first(where: { $0.id == reservationId }) {
                
                let shortID = String(reservation.id.suffix(12))
                Text("Reservation ID: \(shortID)")
                    .font(.title2)
                    .bold()
                
                Text("Booking Date: \(reservation.timestamp, formatter: dateFormatter)")
                    .font(.subheadline)
                
                Text("Booking Time: \(reservation.timestamp, formatter: timeFormatter)")
                    .font(.subheadline)
                
                
                Divider()
                
                Text("Selected Tables & Seats")
                    .font(.headline)
                
                ForEach(reservation.tables, id: \.self) { tableNumber in
                    if let seatArray = reservation.seats[tableNumber], seatArray.contains(true) {
                        let selectedSeatCount = seatArray.filter { $0 }.count
                        HStack {
                            Text("Table \(tableNumber) - \(selectedSeatCount)")
                            Image(systemName: "person.fill")
                        }
                    }
                }
                
                Divider()
                
                Text("Ordered Items")
                    .font(.headline)
                
                if orderVM.orders.isEmpty {
                    Text("No items ordered yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(orderVM.orders) { order in
                        VStack(alignment: .leading, spacing: 7) {
                            let sortedKeys = order.items.keys.sorted() // Precompute sorted keys
                            
                            ForEach(sortedKeys, id: \.self) { key in
                                if let item = order.items[key] {
                                    OrderRow(item: item, orderId: order.id ?? "", reservationId: reservationId, orderVM: orderVM)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    
                    Divider()
                    
                    // Display total price
                    HStack {
                        Text("Total Price: ")
                            .font(.headline)
                        Spacer()
                        let restaurant = businessAuthVM.restaurant
                        Text("\(restaurant?.currencySymbol ?? "")\(totalPrice, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundColor(.mainbw)
                    }
                }
                
                Spacer()
                
                // Print Slip Button
                Button(action: {
                    generatePDF(reservation: reservation)
                }) {
                    HStack {
                        Image(systemName: "printer")
                        Text("Print Slip")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.mainInvert)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.mainbw)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top, 10)
            } else {
                Text("Loading reservation details...")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            orderVM.fetchOrders(reservationId: reservationId)
        }
    }
    
    // MARK: - Generate and Print PDF
    private func generatePDF(reservation: Reservation) {
        let pdfMetaData = [
            kCGPDFContextCreator: "Restaurant App",
            kCGPDFContextAuthor: "Generated by iOS App"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 250 // Standard 80mm receipt printer width
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: 600), format: format)
        
        let pdfData = renderer.pdfData { context in
            context.beginPage()
            
            let titleFont = UIFont.boldSystemFont(ofSize: 16)
            let bodyFont = UIFont.systemFont(ofSize: 12)
            let monospaceFont = UIFont(name: "Courier", size: 12) ?? bodyFont
            
            var yOffset: CGFloat = 20
            let padding: CGFloat = 10
            let priceColumnWidth: CGFloat = 60 // Adjust to fit numbers properly
            
            func drawCenteredText(_ text: String, font: UIFont, bold: Bool = false) {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: bold ? UIFont.boldSystemFont(ofSize: font.pointSize) : font,
                    .paragraphStyle: {
                        let paragraph = NSMutableParagraphStyle()
                        paragraph.alignment = .center
                        return paragraph
                    }()
                ]
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                let textSize = attributedString.size()
                let xPos = (pageWidth - textSize.width) / 2
                attributedString.draw(at: CGPoint(x: xPos, y: yOffset))
                yOffset += 20
            }
            
            func drawLeftText(_ text: String, font: UIFont, bold: Bool = false) {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: bold ? UIFont.boldSystemFont(ofSize: font.pointSize) : font
                ]
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                attributedString.draw(at: CGPoint(x: padding, y: yOffset))
                yOffset += 20
            }
            
            @MainActor func drawItemRow(itemName: String, quantity: Int, price: Double) {
                let restaurant = businessAuthVM.restaurant
                let formattedPrice = String(format: "\(restaurant?.currencySymbol ?? "")%.2f", price)
                let formattedQty = String(format: "%2d", quantity)
                
                _ = pageWidth - (padding + priceColumnWidth) // Leave space for quantity & price
                let truncatedItemName = itemName.count > 15 ? "\(itemName.prefix(15))…" : itemName
                
                // Draw item name (left-aligned)
                let itemAttributes: [NSAttributedString.Key: Any] = [.font: monospaceFont]
                let itemString = NSAttributedString(string: truncatedItemName, attributes: itemAttributes)
                itemString.draw(at: CGPoint(x: padding, y: yOffset))
                
                // Draw quantity & price (right-aligned)
                let qtyPriceString = "\(formattedQty)  \(formattedPrice)"
                let qtyPriceSize = qtyPriceString.size(withAttributes: itemAttributes)
                qtyPriceString.draw(at: CGPoint(x: pageWidth - qtyPriceSize.width - padding, y: yOffset), withAttributes: itemAttributes)
                
                yOffset += 20
            }
            
            // Header
            drawCenteredText("RESTAURANT ORDER SLIP", font: titleFont, bold: true)
            drawCenteredText("Reservation ID: \(String(reservation.id.suffix(12)))", font: bodyFont)
            drawCenteredText("Date: \(dateFormatter.string(from: reservation.timestamp))", font: bodyFont)
            drawCenteredText("Time: \(timeFormatter.string(from: reservation.timestamp))", font: bodyFont)
            
            yOffset += 10
                    drawCenteredText("Table & Seats", font: titleFont, bold: true)
                    
                    drawCenteredText("--------------------------------", font: monospaceFont)
                    
                    // Display Selected Tables and Seats
                    for tableNumber in reservation.tables {
                        if let seatArray = reservation.seats[tableNumber], seatArray.contains(true) {
                            let selectedSeatCount = seatArray.filter { $0 }.count
                            let seatText = "Table \(tableNumber) - \(selectedSeatCount) Seats"
                            drawLeftText(seatText, font: monospaceFont, bold: true)
                        }
                    }
            
            yOffset += 10
            drawCenteredText("Ordered Items", font: titleFont, bold: true)
            
            drawCenteredText("--------------------------------", font: monospaceFont)
            
            // Table Header
            drawCenteredText("Item                                   Qty    Price", font: monospaceFont, bold: true)
            drawCenteredText("--------------------------------", font: monospaceFont)
            
            // Ordered Items
            for order in orderVM.orders {
                for key in order.items.keys.sorted() {
                    if let item = order.items[key] {
                        drawItemRow(itemName: item.name, quantity: item.quantity, price: item.price)
                    }
                }
            }
            
            drawCenteredText("--------------------------------", font: monospaceFont)
            
            yOffset += 10
            let restaurant = businessAuthVM.restaurant
            drawCenteredText(String(format: "TOTAL: \(restaurant?.currencySymbol ?? "")%.2f", totalPrice), font: titleFont, bold: true)
        }
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("OrderSlip.pdf")
        
        do {
            try pdfData.write(to: url)
            print("PDF saved at: \(url)")
            printPDF(url: url)
        } catch {
            print("Could not save PDF: \(error)")
        }
    }


    // MARK: - Print PDF
    private func printPDF(url: URL) {
        let printController = UIPrintInteractionController.shared
        if UIPrintInteractionController.canPrint(url) {
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.jobName = "Order Slip"
            printInfo.outputType = .grayscale
            printController.printInfo = printInfo
            printController.showsNumberOfCopies = true
            printController.printingItem = url
            printController.present(animated: true, completionHandler: nil)
        }
    }
}

struct OrderRow: View {
    let item: OrderItem
    let orderId: String
    let reservationId: String
    @ObservedObject var orderVM: OrdersViewModel
    @EnvironmentObject var businessAuthVM : BusinessAuthViewModel

    var body: some View {
        HStack {
            let restaurant = businessAuthVM.restaurant            
        
            Text("\(item.name) - \(item.quantity) x \(restaurant?.currencySymbol ?? "")\(item.price, specifier: "%.2f")")
                .font(.body)
            Spacer()
            Button(action: {
                orderVM.deleteOrder(orderId: orderId, reservationId: reservationId)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}
