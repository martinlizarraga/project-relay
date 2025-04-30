//
//  TicketView.swift
//  SOPHub
//  Build‑clean 4/30/25 – fixes ForEach syntax and binding typo ($filteredSearchTickets)
//

import SwiftUI

// MARK: - Ticket Model --------------------------------------------------------

struct Ticket: Identifiable, Hashable {
    var id: UUID = UUID()
    var task: String
    var description: String
    var assignedToEmail: String   // empty → unassigned
    var isActive: Bool            // true = open
}

// MARK: - Mock Data -----------------------------------------------------------

private let sampleAssignedTickets: [Ticket] = [
    .init(task: "Fix register issue", description: "Register 2 not scanning barcodes.", assignedToEmail: "employee1@example.com", isActive: true),
    .init(task: "Inventory count update", description: "Recount electronics section.", assignedToEmail: "employee2@example.com", isActive: true)
]

private let sampleUnassignedTickets: [Ticket] = [
    .init(task: "Clean storage area", description: "Sweep and organize.", assignedToEmail: "", isActive: true),
    .init(task: "Update sale signage", description: "Add new promotion signs.", assignedToEmail: "", isActive: true)
]

private let samplePastTickets: [Ticket] = [
    .init(task: "Restock water bottles", description: "Completed restock on 4/15/2025", assignedToEmail: "employee5@example.com", isActive: false),
    .init(task: "Repair freezer", description: "Freezer fixed 4/10/2025", assignedToEmail: "employee6@example.com", isActive: false)
]

// MARK: - View ----------------------------------------------------------------

struct TicketView: View {

    // Sections kept as separate arrays per product decision
    @State private var assignedTickets   = sampleAssignedTickets
    @State private var unassignedTickets = sampleUnassignedTickets
    @State private var pastTickets       = samplePastTickets

    // Search disclosure
    @State private var showSearch = false
    @State private var searchText = ""
    @State private var searchFilter: SearchFilter = .allOpen

    // Detail sheet
    @State private var selectedTicket: Binding<Ticket>? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Assigned Section -----------------------------------
                    SectionHeader("Assigned to Me")
                    TicketSection(tickets: $assignedTickets) { binding in
                        selectedTicket = binding
                    }

                    // Unassigned Section ---------------------------------
                    SectionHeader("Unassigned Open Tickets")
                    TicketSection(tickets: $unassignedTickets) { binding in
                        selectedTicket = binding
                    }

                    // Past Section ---------------------------------------
                    SectionHeader("Past Tickets")
                    TicketSection(tickets: $pastTickets) { binding in
                        selectedTicket = binding
                    }

                    // Search / Filter ------------------------------------
                    DisclosureGroup(isExpanded: $showSearch) {
                        VStack(spacing: 12) {
                            Picker("Filter", selection: $searchFilter) {
                                Text("Assigned to me").tag(SearchFilter.assigned)
                                Text("All open").tag(SearchFilter.allOpen)
                                Text("Closed").tag(SearchFilter.closed)
                                Text("Unassigned").tag(SearchFilter.unassigned)
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: searchFilter) { old, new in
                                print("[DEBUG] Search filter changed from \(old) to \(new)")
                            }

                            TextField("Search…", text: $searchText)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: searchText) { old, new in
                                    print("[DEBUG] Search text → \(new)")
                                }

                            // Read‑only ticket list
                            TicketSectionReadOnly(tickets: filteredSearchTickets)
                        }
                        .padding(.vertical, 8)
                    } label: {
                        Text("Search Tickets").font(.title2).bold()
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Tickets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Add new ticket – for now append dummy and open sheet
                        let new = Ticket(task: "New ticket", description: "", assignedToEmail: "", isActive: true)
                        unassignedTickets.insert(new, at: 0)
                        if let idx = unassignedTickets.firstIndex(where: { $0.id == new.id }) {
                            selectedTicket = $unassignedTickets[idx]
                        }
                        print("[DEBUG] New ticket created and sheet opened")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $selectedTicket) { $ticket in
                TicketDetailView(ticket: $ticket)
            }
            .onAppear {
                print("[DEBUG] TicketView appeared – assigned: \(assignedTickets.count), unassigned: \(unassignedTickets.count), past: \(pastTickets.count)")
            }
        }
    }

    // MARK: - Derived search array -------------------------------------------

    private var filteredSearchTickets: [Ticket] {
        var pool = assignedTickets + unassignedTickets + pastTickets
        switch searchFilter {
        case .assigned:   pool = pool.filter { !$0.assignedToEmail.isEmpty }
        case .allOpen:    pool = pool.filter { $0.isActive }
        case .closed:     pool = pool.filter { !$0.isActive }
        case .unassigned: pool = pool.filter { $0.assignedToEmail.isEmpty && $0.isActive }
        }
        if !searchText.isEmpty {
            pool = pool.filter { $0.task.localizedCaseInsensitiveContains(searchText) || $0.description.localizedCaseInsensitiveContains(searchText) }
        }
        return pool
    }

    // MARK: - Helpers ---------------------------------------------------------

    enum SearchFilter: String, CaseIterable { case assigned, allOpen, closed, unassigned }
}

// MARK: - TicketSection (editable) -------------------------------------------

private struct TicketSection: View {
    @Binding var tickets: [Ticket]
    var cardTapped: (Binding<Ticket>) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(tickets.indices, id: \.self) { idx in
                TicketCard(ticket: $tickets[idx]) {
                    cardTapped($tickets[idx])
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - TicketSectionReadOnly ---------------------------------------------

private struct TicketSectionReadOnly: View {
    var tickets: [Ticket]
    var body: some View {
        VStack(spacing: 12) {
            ForEach(tickets) { ticket in
                CardBase {
                    HStack {
                        Text(ticket.task).font(.headline)
                        Spacer()
                        Text(ticket.isActive ? "Active" : "Closed")
                            .font(.caption).bold().foregroundColor(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(ticket.isActive ? Color.yellow : Color.green).cornerRadius(6)
                    }
                    Text(ticket.description).font(.subheadline).foregroundColor(.secondary)
                    Text("Assigned to: " + (ticket.assignedToEmail.isEmpty ? "None" : ticket.assignedToEmail))
                        .font(.caption)
                        .foregroundColor(ticket.assignedToEmail.isEmpty ? .red : .blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - TicketCard ----------------------------------------------------------

private struct TicketCard: View {
    @Binding var ticket: Ticket
    var onTap: () -> Void

    var body: some View {
        CardBase {
            HStack {
                Text(ticket.task).font(.headline)
                Spacer()
                Menu {
                    Button(ticket.isActive ? "Mark Closed" : "Reopen") {
                        ticket.isActive.toggle()
                        print("[DEBUG] Status toggled for \(ticket.task) → \(ticket.isActive ? "Open" : "Closed")")
                    }
                } label: {
                    Text(ticket.isActive ? "Active" : "Closed")
                        .font(.caption).bold().foregroundColor(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(ticket.isActive ? Color.yellow : Color.green).cornerRadius(6)
                }
            }

            Text(ticket.description).font(.subheadline).foregroundColor(.secondary)

            Text("Assigned to: " + (ticket.assignedToEmail.isEmpty ? "None" : ticket.assignedToEmail))
                .font(.caption)
                .foregroundColor(ticket.assignedToEmail.isEmpty ? .red : .blue)
        }
        .onTapGesture { onTap() }
        .onAppear { print("[DEBUG] TicketCard appear – \(ticket.task)") }
    }
}

// MARK: - Shared Card Shell ---------------------------------------------------

private struct CardBase<Content: View>: View {
    var background: Color = Color(UIColor.secondarySystemBackground)
    var shadow: Color = .gray.opacity(0.3)
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 6) { content }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background).cornerRadius(12)
            .shadow(color: shadow, radius: 2, x: 0, y: 2)
            .padding(.horizontal)
    }
}

// MARK: - Section Header ------------------------------------------------------

private struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.title2).bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

// MARK: - Preview ------------------------------------------------------------

#Preview {
    TicketView()
}
