//
//  ContentView.swift
//  SOPHub
//
//  Created by Martin Lizarraga on 4/21/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View{
        NavigationView{
            VStack(spacing: 20){
                HStack{
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    Text("SOP Hub")
                        .font(.title)
                        .bold()
                    Spacer()
                }.padding()
                
                VStack(spacing: 16) {
                    SOPButton(icon: "square.grid.2x2", text: "Inventory", destination: InventoryView())
                    SOPButton(icon: "creditcard", text: "Sales and Register", destination: SalesView())
                    SOPButton(icon: "wrench.and.screwdriver", text: "Maintenance and Clearning", destination: MaintenanceView())
                    SOPButton(icon: "chart.line.uptrend.xyaxis", text: "Porn", destination: AnalyticsView())
                }.padding()
                Spacer()
            }.navigationBarHidden(true)
        }
    }
}

struct SOPButton<Destination: View>: View {
    var icon: String
    var text: String
    var destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination){
            HStack{
                Image(systemName: icon).font(.title2).frame(width: 30)
                Text(text).font(.headline)
                Spacer()
            }.padding().background(
                RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }.buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}
