//  TicketDetailView.swift
//  SOPHub
//  Rev 8 – visual tweaks only (per user request)
//  • Cards now have 8‑pt horizontal margins so they don’t hug screen edges.
//  • Gap between Title and Description cards reduced from 24 pt → 14 pt.
//  No functional logic changed.
//
//  Compiles on Xcode 16E140.
//

import SwiftUI
import PhotosUI

// MARK: - Comment Model ------------------------------------------------------

struct TicketComment: Identifiable, Hashable {
    let id: UUID = UUID()
    var author: String
    var timestamp: Date = .now
    var text: String
    var imageData: Data? = nil // optional photo attachment
}

// MARK: - Shared Card Shell --------------------------------------------------

/// Slightly lifted card with subtle stroke and now horizontal margin.
private struct CardBase<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) { content }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray3), lineWidth: 0.8)
            )
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
            .padding(.horizontal, 8) // ← new side margin
    }
}

// MARK: - Ticket Detail View -------------------------------------------------

struct TicketDetailView: View {
    @Binding var ticket: Ticket
    @Environment(\.dismiss) private var dismiss

    // Mock current user email (replace with auth later)
    private let currentUserEmail = "me@example.com"

    // Employee list including pseudo‑option ------------------------------
    private var employees: [String] {
        ["", "Assign to me", currentUserEmail, "employee1@example.com", "employee2@example.com"]
    }

    // Ticket‑level attachments -----------------------------------------
    @State private var ticketImages: [Image] = []
    @State private var ticketPickerItem: PhotosPickerItem? = nil

    // Comment composer ---------------------------------------------------
    @State private var draftText: String = ""
    @State private var draftPickerItem: PhotosPickerItem? = nil
    @State private var draftImageData: Data? = nil

    // Comment thread (newest first) -------------------------------------
    @State private var comments: [TicketComment] = [
        .init(author: "bob@example.com", text: "Reboot didn't help, still broken."),
        .init(author: "jane@example.com", text: "Please check the scanner cable — had the same issue yesterday.")
    ]
    @State private var editingComment: TicketComment? = nil
    @State private var editedText: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // TITLE + DESCRIPTION (tighter internal gap) -------
                    VStack(spacing: 14) {
                        // TITLE -----------------------------------
                        CardBase {
                            TextField("Title", text: $ticket.task)
                                .font(.title2).bold()
                                .textFieldStyle(.plain)
                        }

                        // DESCRIPTION ------------------------------
                        CardBase {
                            ZStack(alignment: .topLeading) {
                                if ticket.description.isEmpty {
                                    Text("Description")
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                        .padding(.horizontal, 5)
                                }
                                TextEditor(text: $ticket.description)
                                    .frame(minHeight: 140)
                                    .scrollContentBackground(.hidden)
                            }
                        }
                    }

                    // STATUS -----------------------------------------
                    CardBase {
                        Text("Status").font(.headline)
                        Menu {
                            Button("Open")   { ticket.isActive = true }
                            Button("Closed") { ticket.isActive = false }
                        } label: {
                            pickerLabel(ticket.isActive ? "Open" : "Closed")
                        }
                    }

                    // ASSIGNEE ---------------------------------------
                    CardBase {
                        Text("Assignee").font(.headline)
                        Menu {
                            ForEach(employees, id: \.self) { email in
                                Button(email.isEmpty ? "Unassigned" : email) {
                                    if email == "Assign to me" {
                                        ticket.assignedToEmail = currentUserEmail
                                    } else {
                                        ticket.assignedToEmail = email
                                    }
                                }
                            }
                        } label: {
                            pickerLabel(ticket.assignedToEmail.isEmpty ? "Unassigned" : ticket.assignedToEmail)
                        }
                    }

                    // ATTACHMENTS ------------------------------------
                    CardBase {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Attachments").font(.headline)
                            if ticketImages.isEmpty {
                                Text("No attachments yet").foregroundColor(.secondary)
                            } else {
                                ForEach(ticketImages.indices, id: \.self) { idx in
                                    ticketImages[idx]
                                        .resizable().scaledToFit()
                                        .frame(maxHeight: 120)
                                        .cornerRadius(8)
                                }
                            }
                            PhotosPicker(selection: $ticketPickerItem, matching: .images) {
                                Label("Add Attachment", systemImage: "paperclip")
                            }
                            .buttonStyle(.bordered)
                            .onChange(of: ticketPickerItem) { _, item in
                                if let item = item { loadTicketImage(from: item) }
                            }
                        }
                    }

                    // COMMENTS ---------------------------------------
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Comments").font(.title3).bold().padding(.horizontal)

                        // Composer --------------------------------
                        CardBase {
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Add a comment…", text: $draftText, axis: .vertical)
                                    .textFieldStyle(.plain)
                                HStack {
                                    PhotosPicker(selection: $draftPickerItem, matching: .images) {
                                        Image(systemName: "paperclip")
                                    }
                                    .onChange(of: draftPickerItem) { _, item in
                                        if let item = item { loadDraftImage(from: item) }
                                    }
                                    Spacer()
                                    Button("Send", action: postComment)
                                        .disabled(draftText.trimmingCharacters(in: .whitespaces).isEmpty && draftImageData == nil)
                                }
                            }
                        }

                        // Thread -----------------------------------
                        ForEach(comments) { comment in
                            CommentRow(comment: comment,
                                       canEdit: comment.author == currentUserEmail,
                                       onEdit: { startEdit(comment) },
                                       onDelete: { deleteComment(comment) })
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("New Ticket Details")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
            .sheet(item: $editingComment) { _ in editSheet }
        }
    }

    // MARK: - Picker Label ------------------------------------------------
    private func pickerLabel(_ text: String) -> some View {
        HStack {
            Text(text)
            Spacer()
            Image(systemName: "chevron.down")
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    // MARK: - Image Loading ----------------------------------------------
    private func loadTicketImage(from item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                ticketImages.append(Image(uiImage: uiImage))
            }
            ticketPickerItem = nil
        }
    }

    private func loadDraftImage(from item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                draftImageData = data
            }
            draftPickerItem = nil
        }
    }

    // MARK: - Comment Actions --------------------------------------------
    private func postComment() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty || draftImageData != nil else { return }
        comments.insert(TicketComment(author: currentUserEmail, text: trimmed, imageData: draftImageData), at: 0)
        draftText = ""
        draftImageData = nil
    }

    private func startEdit(_ comment: TicketComment) {
        editingComment = comment
        editedText = comment.text
    }

    private func deleteComment(_ comment: TicketComment) {
        comments.removeAll { $0.id == comment.id }
    }

    // MARK: - Edit Sheet ---------------------------------------------------
    private var editSheet: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $editedText)
                    .padding()
                Spacer()
            }
            .navigationTitle("Edit Comment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { editingComment = nil } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let id = editingComment?.id,
                           let idx = comments.firstIndex(where: { $0.id == id }) {
                            comments[idx].text = editedText
                        }
                        editingComment = nil
                    }
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Comment Row -------------------------------------------------------

private struct CommentRow: View {
    let comment: TicketComment
    var canEdit: Bool
    var onEdit: () -> Void
    var onDelete: () -> Void

    private static let tsFormatter: DateFormatter = {
        let df = DateFormatter(); df.dateStyle = .medium; df.timeStyle = .short; return df
    }()

    var body: some View {
        CardBase {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(comment.author).bold()
                    Text(comment.timestamp, formatter: Self.tsFormatter)
                        .font(.caption).foregroundColor(.secondary)
                    Text(comment.text)
                    if let data = comment.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable().scaledToFit()
                            .frame(maxHeight: 120)
                            .cornerRadius(6)
                    }
                }
                if canEdit {
                    Menu {
                        Button("Edit", action: onEdit)
                        Button("Delete", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .padding(.horizontal, 4)
                    }
                }
            }
        }
    }
}

// MARK: - Preview -----------------------------------------------------------

#Preview {
    struct PreviewWrapper: View {
        @State var previewTicket = Ticket(task: "", description: "", assignedToEmail: "", isActive: true)
        var body: some View { TicketDetailView(ticket: $previewTicket) }
    }
    return PreviewWrapper()
}
