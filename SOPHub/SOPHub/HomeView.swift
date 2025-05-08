//
//  HomeView.swift
//  SOPHub
//

import SwiftUI

struct HomeView: View {
    @State private var selectedView: SOPDestination? = .dashboard   // ← default now

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedView) {
                NavigationLink(value: SOPDestination.dashboard) {   // ← NEW
                    Label("Home", systemImage: "house")
                }
                NavigationLink(value: SOPDestination.tickets) {
                    Label("Tickets", systemImage: "ticket")
                }
                NavigationLink(value: SOPDestination.inventory) {
                    Label("Inventory", systemImage: "square.grid.2x2")
                }
                NavigationLink(value: SOPDestination.sales) {
                    Label("Sales and Register", systemImage: "creditcard")
                }
                NavigationLink(value: SOPDestination.maintenance) {
                    Label("Maintenance and Cleaning", systemImage: "wrench.and.screwdriver")
                }
                NavigationLink(value: SOPDestination.analytics) {
                    Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                }
            }
            .navigationTitle("SOP Hub")
        } detail: {
            // Detail View
            switch selectedView {
            case .dashboard:
                DashboardView()                                 // ← NEW
            case .tickets:
                TicketView()
            case .inventory:
                InventoryView()
            case .sales:
                SalesView()
            case .maintenance:
                MaintenanceView()
            case .analytics:
                AnalyticsView()
            case .none:
                Text("Select a section")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Destination Enum
enum SOPDestination: Hashable {
    case dashboard     // ← NEW
    case tickets
    case inventory
    case sales
    case maintenance
    case analytics
}

#Preview {
    HomeView()
}
