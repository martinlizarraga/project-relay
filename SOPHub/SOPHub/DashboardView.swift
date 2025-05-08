//  DashboardView.swift
//  SOPHub
//  Rev 3 – remove duplicate sidebar icon (system provides one already)
//
//  Created by ChatGPT on 5/7/25.
//

import SwiftUI

// MARK: - Domain -----------------------------------------------------------------

/// Lightweight model for store announcements
struct Bulletin: Identifiable, Hashable {
    let id: UUID = UUID()
    var title: String
    var body: String
    var postedAt: Date = .now
}

private let sampleBulletins: [Bulletin] = [
    .init(title: "Weekend Promo",       body: "20% off starts Friday – update signage."),
    .init(title: "New Closing SOP",     body: "Review the updated checklist before tonight."),
    .init(title: "Safety Training",     body: "All staff must complete module by 5/15.")
]

// MARK: - View --------------------------------------------------------------------

struct DashboardView: View {

    // Mock KPI counts – wire to shared store later
    @State private var openTicketCount: Int = 4
    @State private var oosCount: Int = 2
    @State private var openIssueCount: Int = 3

    // Bulletins
    @State private var bulletins: [Bulletin] = sampleBulletins

    // Sheet state for Create Ticket quick‑action
    @State private var showCreateTicket: Bool = false
    @State private var draftTicket      = Ticket(task: "New ticket", description: "", assignedToEmail: "", isActive: true)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    statCardsRow
                    quickActionsRow
                    bulletinsSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showCreateTicket) {
                TicketDetailView(ticket: $draftTicket)
            }
        }
    }

    // MARK: UI Components -------------------------------------------------------

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Good \(greetingTime()), Tristan and Martin!")
                .font(.largeTitle).bold()
            Text(Date.now, style: .date)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }

    // ---- KPI Stat Cards ------------------------------------------------------

    private var statCardsRow: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Open Tickets",
                count: openTicketCount,
                systemImage: "ticket.fill",
                destination: AnyView(TicketView())
            )
            statCard(
                title: "OOS SKUs",
                count: oosCount,
                systemImage: "cube.box.fill",
                destination: AnyView(InventoryView())
            )
            statCard(
                title: "Maintenance",
                count: openIssueCount,
                systemImage: "wrench.and.screwdriver.fill",
                destination: AnyView(MaintenanceView())
            )
        }
        .padding(.horizontal)
    }

    @ViewBuilder private func statCard(title: String, count: Int, systemImage: String, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            CardBase {
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundColor(.accentColor)
                    Text("\(count)").font(.title).bold()
                    Text(title).font(.caption).foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // ---- Quick Actions -------------------------------------------------------

    private var quickActionsRow: some View {
        HStack(spacing: 16) {
            Button {
                showCreateTicket = true
            } label: {
                Label("Create Ticket", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)

            NavigationLink(destination: InventoryView()) {
                Label("Receive Inventory", systemImage: "tray.and.arrow.down")
            }
            .buttonStyle(.bordered)

            NavigationLink(destination: MaintenanceView()) {
                Label("Start Checklist", systemImage: "checklist")
            }
            .buttonStyle(.bordered)
        }
        .font(.caption)
        .padding(.horizontal)
    }

    // ---- Bulletins -----------------------------------------------------------

    private var bulletinsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bulletins").font(.title2).bold()
            ForEach(bulletins) { bulletin in
                CardBase {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bulletin.title).font(.headline)
                        Text(bulletin.body).font(.subheadline).foregroundColor(.secondary)
                        Text(bulletin.postedAt, style: .time)
                            .font(.caption2).foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: Helpers -----------------------------------------------------------

    /// Returns "morning / afternoon / evening" string
    private func greetingTime() -> String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12:  return "morning"
        case 12..<18: return "afternoon"
        default:      return "evening"
        }
    }
}

// MARK: - Shared Card Shell ---------------------------------------------------

private struct CardBase<Content: View>: View {
    var background: Color = Color(UIColor.secondarySystemBackground)
    var shadow: Color = .gray.opacity(0.3)
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .cornerRadius(12)
            .shadow(color: shadow, radius: 2, x: 0, y: 2)
    }
}

// MARK: - Preview -------------------------------------------------------------

#Preview {
    DashboardView()
}
