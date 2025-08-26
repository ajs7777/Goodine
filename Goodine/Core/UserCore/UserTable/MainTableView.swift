

import SwiftUI

struct MainTableView: View {
    
    @EnvironmentObject var tableVM : TableViewModel
    
    @State private var showOrdersSheet = false
    
    var body: some View {
        ZStack {
            Image(.foodTexture)
                .renderingMode(.template)
                .resizable()
                .scaledToFill()
                .foregroundStyle(.gray.opacity(0.2))
            
            if tableVM.reservations.isEmpty {
                VStack{
                    Image(.businessicon)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.mainbw.opacity(0.3))
                        .frame(width: 200, height: 310)
                    
                    Text("Sorry, no available reservations ")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.mainbw.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                    
                }
            } else {
                VStack {
                    
                    Spacer()
                    
                    Text("Current Order")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.mainbw)
                    
                    Spacer()
                    
                    activeOrders
                    
                    Spacer()
                    
                    Button {
                        SoundManager.shared.playSound(named: "taptup")
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundStyle(.mainInvert)
                                .frame(width: 300, height: 300)
                                .shadow(color: .mainbw.opacity(0.2), radius: 10, x: 5, y: 5)
                            Image(.table)
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 280, height: 280)
                                .foregroundStyle(.mainbw.opacity(0.3))
                        } }
                    
                    Spacer()
                    
                    Button {
                        showOrdersSheet = true
                    } label: {
                        Text("Show Orders")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .sheet(isPresented: $showOrdersSheet) {
                        if let firstReservation = tableVM.reservations.first {
                            ShowOrdersView(reservationId: firstReservation.id)
                        }
                    }
                    
                    Spacer()
                    
                }
            }
        }
        
    }
    
}

#Preview {
    MainTableView()
}

extension MainTableView {
    private var activeOrders: some View {
        Group {
            if tableVM.reservations.count > 2 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        reservationViews
                    }
                    .padding(.horizontal)
                }
            } else {
                HStack(spacing: 12) {
                    reservationViews
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var reservationViews: some View {
        ForEach(tableVM.reservations, id: \.id) { reservation in
            VStack(alignment: .leading, spacing: 6) {
                ForEach(
                    reservation.tables.filter { tableNumber in
                        let seatArray = reservation.seats[tableNumber] ?? []
                        return seatArray.contains(true)
                    },
                    id: \.self
                ) { tableNumber in
                    let seatArray = reservation.seats[tableNumber] ?? []
                    let selectedSeatCount = seatArray.filter { $0 }.count
                    
                    if selectedSeatCount > 0 {
                        HStack(spacing: 4) {
                            Text("Table \(tableNumber) : \(selectedSeatCount)")
                            Image(systemName: "person.fill")
                        }
                    }
                }
            }
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.mainInvert)
            .padding()
            .background(.mainbw)
            .cornerRadius(12)
            
        }
    }
}

