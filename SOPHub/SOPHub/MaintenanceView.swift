//
//  MaintenanceView.swift
//  SOPHub
//  Updated 4/30/25 – red badge, extra cleaning tasks, Instructions button,
//  and iOS 17‑style two‑parameter onChange closure.
//

import SwiftUI

// MARK: - Domain --------------------------------------------------------------

/// Recurring cleaning / maintenance task (SOP‑driven)
struct CleaningTask: Identifiable, Hashable {
    let id: UUID = UUID()
    var title: String            // e.g. "Disinfect countertops"
    var schedule: String         // e.g. "Every 2 hrs"
    var lastDone: Date?
    var dueTime: Date?           // optional explicit due today
    var doneToday: Bool          // quick status flag
}

/// Open maintenance ticket (subset of global Ticket)
struct MaintenanceTicket: Identifiable, Hashable {
    let id: UUID = UUID()
    var title: String
    var description: String
    var createdAt: Date = .now
}

// MARK: - Mock Data -----------------------------------------------------------

private var sampleCleaning: [CleaningTask] = [
    .init(title: "Sweep & mop floor",         schedule: "End of day",           lastDone: .now.addingTimeInterval(-86_400),          dueTime: nil,                                   doneToday: false),
    .init(title: "Disinfect countertops",     schedule: "Every 2 hrs",          lastDone: nil,                                         dueTime: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: .now), doneToday: false),
    .init(title: "Clean bathroom",            schedule: "Open & close",          lastDone: .now.addingTimeInterval(-14_400),          dueTime: nil,                                   doneToday: true),
    // New tasks
    .init(title: "Empty trash bins",          schedule: "End of day",           lastDone: nil,                                         dueTime: nil,                                   doneToday: false),
    .init(title: "Sanitise POS terminals",    schedule: "Every shift change",   lastDone: nil,                                         dueTime: nil,                                   doneToday: false),
    .init(title: "Restock restroom supplies", schedule: "Daily",                lastDone: .now.addingTimeInterval(-93_600),          dueTime: nil,                                   doneToday: false),
    .init(title: "Clean front windows",       schedule: "Weekly (Mon)",         lastDone: nil,                                         dueTime: nil,                                   doneToday: false)
]

private var sampleTickets: [MaintenanceTicket] = [
    .init(title: "Leaking toilet pipe",      description: "Small puddle behind bathroom toilet."),
    .init(title: "Flickering ceiling light", description: "Front register – bulb or ballast?"),
    .init(title: "HVAC not cooling",         description: "Thermostat set 72 °F, store holding 78 °F.")
]

// MARK: - View ----------------------------------------------------------------

struct MaintenanceView: View {
    private enum Tab: String, CaseIterable { case cleaning = "Cleaning", issues = "Issues" }

    @State private var selectedTab: Tab = .cleaning
    @State private var cleaning = sampleCleaning
    @State private var tickets  = sampleTickets

    // Computed each render for dynamic badge
    private var openIssueCount: Int { tickets.count }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                segmentControl
                    .padding([.horizontal, .top])

                ScrollView {
                    if selectedTab == .cleaning {
                        cleaningList
                    } else {
                        issuesList
                    }
                }
            }
            .navigationTitle("Maintenance")
            .onAppear {
                print("[DEBUG] MaintenanceView appeared – cleaning tasks: \(cleaning.count), tickets: \(tickets.count)")
            }
        }
    }

    // MARK: UI Components ---------------------------------------------------

    private var segmentControl: some View {
        ZStack(alignment: .trailing) {
            Picker("Tab", selection: $selectedTab) {
                Text(Tab.cleaning.rawValue).tag(Tab.cleaning)
                Text(Tab.issues.rawValue).tag(Tab.issues)
            }
            .pickerStyle(.segmented)

            if openIssueCount > 0 && selectedTab == .cleaning {
                Text("\(openIssueCount)")
                    .font(.caption2).bold()
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: -12, y: -10) // adjust for device
                    .accessibilityLabel("\(openIssueCount) open maintenance issues")
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            print("[DEBUG] switched tab: \(oldValue.rawValue) → \(newValue.rawValue)")
        }
    }

    private var cleaningList: some View {
        VStack(spacing: 12) {
            ForEach($cleaning) { $task in
                CleaningCard(task: $task) {
                    // Action: create ticket from task context
                    let newTicket = MaintenanceTicket(title: "Issue with \(task.title)", description: "Raised from Cleaning task")
                    tickets.append(newTicket)
                    print("[DEBUG] Created ticket from task – id: \(newTicket.id)")
                }
            }
        }
        .padding(.vertical)
    }

    private var issuesList: some View {
        VStack(spacing: 12) {
            ForEach($tickets) { $ticket in
                IssueCard(ticket: ticket)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Cleaning Card -------------------------------------------------------

private struct CleaningCard: View {
    @Binding var task: CleaningTask
    var createTicket: () -> Void

    var body: some View {
        CardBase {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title).font(.headline)
                    Text(task.schedule).font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                StatusPill(done: task.doneToday)
            }

            if task.doneToday, let last = task.lastDone {
                Text("Completed at \(last, formatter: Self.timeFormatter)")
                    .font(.caption).foregroundColor(.secondary)
            } else if let due = task.dueTime {
                Text("Due by \(due, formatter: Self.timeFormatter)")
                    .font(.caption).foregroundColor(.red)
            }

            HStack(spacing: 16) {
                Button(action: toggleDone) {
                    Label(task.doneToday ? "Mark Pending" : "Mark Done", systemImage: task.doneToday ? "arrow.uturn.backward" : "checkmark.circle")
                }
                .buttonStyle(.borderedProminent)

                Button(action: createTicket) {
                    Label("Create Ticket", systemImage: "plus.rectangle.on.rectangle")
                }
                .buttonStyle(.bordered)

                Button(action: openInstructions) {
                    Label("Instructions", systemImage: "book")
                }
                .buttonStyle(.bordered)
            }
            .font(.caption)
        }
        .onAppear { print("[DEBUG] CleaningCard – \(task.title) doneToday: \(task.doneToday)") }
    }

    private func toggleDone() {
        task.doneToday.toggle()
        task.lastDone = task.doneToday ? .now : nil
        print("[DEBUG] Toggled doneToday for \(task.title) → \(task.doneToday)")
    }

    private func openInstructions() {
        // Placeholder – eventually navigate to SOP detail view
        print("[DEBUG] Open Instructions for \(task.title)")
    }

    private struct StatusPill: View {
        let done: Bool
        var body: some View {
            Text(done ? "Done" : "Pending")
                .font(.caption).bold().foregroundColor(.white)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(done ? Color.green : Color.yellow).cornerRadius(6)
        }
    }

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter(); df.timeStyle = .short; return df }()
}

// MARK: - Issue Card ----------------------------------------------------------

private struct IssueCard: View {
    let ticket: MaintenanceTicket

    var body: some View {
        CardBase(background: Color.red.opacity(0.12), shadow: Color.red.opacity(0.25)) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white).padding(4)
                    .background(Color.red).clipShape(Circle())
                Text(ticket.title).font(.headline)
            }
            Text(ticket.description).font(.subheadline).foregroundColor(.secondary)
        }
        .onAppear { print("[DEBUG] IssueCard appeared – \(ticket.title)") }
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
            .background(background).cornerRadius(12)
            .shadow(color: shadow, radius: 2, x: 0, y: 2)
            .padding(.horizontal)
    }
}

// MARK: - Preview -------------------------------------------------------------

#Preview { MaintenanceView() }
