//
//  TicketView.swift
//  SOPHub
//
//  Created by Martin Lizarraga on 4/27/25.
//

import SwiftUI

struct TicketView: View {
    @State private var assignedTickets: [Ticket] = sampleAssignedTickets
    @State private var openTickets: [Ticket] = sampleOpenTickets
    @State private var pastTickets: [Ticket] = samplePastTickets
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Assigned Tickets Section
                    Text("Assigned Tickets")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    TicketSection(tickets: assignedTickets)
                    
                    // Open Tickets Section
                    Text("Open Tickets")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    TicketSection(tickets: openTickets)
                    
                    // Past Tickets Section
                    Text("Past Tickets")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    TicketSection(tickets: pastTickets)
                }
                .padding(.top)
            }
            .navigationTitle("Tickets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Later: open a form to create a new ticket
                        print("New Ticket tapped")
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

// MARK: - Ticket Section View
struct TicketSection: View {
    var tickets: [Ticket]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(tickets) { ticket in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(ticket.task)
                            .font(.headline)
                        Spacer()
                        Text(ticket.isActive ? "Active" : "Closed")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(6)
                            .background(ticket.isActive ? Color.yellow : Color.green)
                            .cornerRadius(6)
                    }
                    
                    Text(ticket.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if ticket.assignedToEmail.isEmpty {
                        Text("Assigned to: None")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else {
                        Text("Assigned to: \(ticket.assignedToEmail)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 2)
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Ticket Model
struct Ticket: Identifiable {
    var id = UUID()
    var task: String
    var description: String
    var assignedToEmail: String
    var isActive: Bool
}

// MARK: - Sample Data
let sampleAssignedTickets = [
    Ticket(task: "Fix register issue", description: "Register 2 not scanning barcodes.", assignedToEmail: "employee1@example.com", isActive: true),
    Ticket(task: "Inventory count update", description: "Recount electronics section.", assignedToEmail: "employee2@example.com", isActive: true)
]

let sampleOpenTickets = [
    Ticket(task: "Clean storage area", description: "Sweep and organize.", assignedToEmail: "", isActive: true),
    Ticket(task: "Update sale signage", description: "Add new promotion signs.", assignedToEmail: "", isActive: true)
]

let samplePastTickets = [
    Ticket(task: "Restock water bottles", description: "Completed restock on 4/15/2025", assignedToEmail: "employee5@example.com", isActive: false),
    Ticket(task: "Repair freezer", description: "Freezer fixed 4/10/2025", assignedToEmail: "employee6@example.com", isActive: false)
]

#Preview {
    TicketView()
}
