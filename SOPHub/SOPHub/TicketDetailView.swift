//
//  TicketDetailView.swift
//  SOPHub
//  Fixed 4/30/25 – preview wrapper added to satisfy @State macro rule
//

import SwiftUI

/// Detail / edit sheet for a single Ticket. Requires a binding so edits propagate
/// back to the list.
struct TicketDetailView: View {
    @Binding var ticket: Ticket
    @Environment(\.dismiss) private var dismiss

    // Mock employee list – replace with real users later
    private let employees = ["", "employee1@example.com", "employee2@example.com", "employee3@example.com"]

    // Simple comment placeholder
    @State private var commentDraft: String = ""
    @State private var comments: [String] = [
        "Placeholder comment #1",
        "Placeholder comment #2"
    ]

    var body: some View {
        NavigationStack {
            Form {
                // DETAILS
                Section("Details") {
                    TextField("Title", text: $ticket.task)
                    TextEditor(text: $ticket.description)
                        .frame(minHeight: 120)
                }

                // STATUS
                Section("Status") {
                    Picker("Status", selection: $ticket.isActive) {
                        Text("Open").tag(true)
                        Text("Closed").tag(false)
                    }
                    .pickerStyle(.segmented)
                }

                // ASSIGNEE
                Section("Assignee") {
                    Picker("Assign to", selection: $ticket.assignedToEmail) {
                        ForEach(employees, id: \.self) { email in
                            Text(email.isEmpty ? "Unassigned" : email).tag(email)
                        }
                    }
                }

                // COMMENTS (placeholder)
                Section("Comments") {
                    ForEach(comments, id: \.self) { Text($0) }
                    HStack {
                        TextField("Add a comment…", text: $commentDraft)
                        Button("Send") {
                            let trimmed = commentDraft.trimmingCharacters(in: .whitespaces)
                            guard !trimmed.isEmpty else { return }
                            comments.append(trimmed)
                            commentDraft = ""
                        }
                        .disabled(commentDraft.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .navigationTitle("Ticket")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}

// MARK: - Preview -------------------------------------------------------------

#Preview {
    struct PreviewWrapper: View {
        @State var previewTicket = Ticket(task: "Fix register issue",
                                          description: "Register 2 not scanning barcodes.",
                                          assignedToEmail: "employee1@example.com",
                                          isActive: true)
        var body: some View { TicketDetailView(ticket: $previewTicket) }
    }
    return PreviewWrapper()
}
