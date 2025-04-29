//
//  MaintenanceView.swift
//  SOPHub
//  Finalised by ChatGPT on 4/28/25 – add due-time call-out for pending cleaning task
//

import SwiftUI

// MARK: - Domain ---------------------------------------------------------------

struct SupplyItem: Identifiable {
    let id = UUID()
    let name: String
    let usage: String
}

struct CleaningTask: Identifiable {
    let id = UUID()
    let area: String
    let details: String
    let doneToday: Bool
    let completedBy: String?
    let completedTime: Date?
    let dueTime: Date?                  // << new
}

struct MaintenanceIssue: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

// MARK: Mock Data --------------------------------------------------------------

private let sampleSupplies: [SupplyItem] = [
    .init(name: "Windex",              usage: "Glass & window cleaner"),
    .init(name: "Multi-Surface Spray", usage: "Counters & tables"),
    .init(name: "Disinfectant Wipes",  usage: "Quick sanitizing / POS screens"),
    .init(name: "Floor Degreaser",     usage: "Back-room tile & spills")
]

private let sampleCleaning: [CleaningTask] = [
    .init(area: "Floor",
          details: "Sweep & mop – end of day",
          doneToday: true,
          completedBy: "Emma L.",
          completedTime: Calendar.current.date(bySettingHour: 9,  minute: 32, second: 0, of: .now),
          dueTime: nil),
    
    .init(area: "Countertops",
          details: "Disinfect every 2 hrs",
          doneToday: false,
          completedBy: nil,
          completedTime: nil,
          dueTime: Calendar.current.date(bySettingHour: 18, minute: 0,  second: 0, of: .now)),  // 6 PM
    
    .init(area: "Bathroom",
          details: "Full clean – open & close",
          doneToday: true,
          completedBy: "Carlos R.",
          completedTime: Calendar.current.date(bySettingHour: 12, minute: 15, second: 0, of: .now),
          dueTime: nil)
]

private let sampleIssues: [MaintenanceIssue] = [
    .init(title: "Leaking toilet pipe",      description: "Small puddle behind bathroom toilet."),
    .init(title: "Flickering ceiling light", description: "Front register – bulb or ballast?"),
    .init(title: "HVAC not cooling",         description: "Thermostat 72 °F, store holding 78 °F.")
]

// MARK: - View -----------------------------------------------------------------

struct MaintenanceView: View {
    @State private var supplies = sampleSupplies
    @State private var cleaning = sampleCleaning
    @State private var issues   = sampleIssues
    
    var body: some View { /* unchanged */ NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                SectionHeader("Supplies")
                VStack(spacing: 12) { ForEach(supplies) { SupplyCard(item: $0) } }
                
                SectionHeader("Cleaning")
                VStack(spacing: 12) { ForEach(cleaning) { CleaningCard(task: $0) } }
                
                SectionHeader("Issues / Problems")
                VStack(spacing: 12) { ForEach(issues) { IssueCard(issue: $0) } }
            }
            .padding(.vertical)
        }
        .navigationTitle("Maintenance")
    }}
}

// MARK: - Section Header (unchanged) -------------------------------------------

private struct SectionHeader: View { /* unchanged */ let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title).font(.title2).bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
}

// MARK: - Cards -----------------------------------------------------------------

private struct SupplyCard: View { /* unchanged */ let item: SupplyItem
    var body: some View { CardBase {
        Text(item.name).font(.headline)
        Text(item.usage).font(.subheadline).foregroundColor(.secondary)
    }}
}

private struct CleaningCard: View {
    let task: CleaningTask
    
    var body: some View { CardBase {
        HStack {
            Text(task.area).font(.headline)
            Spacer()
            StatusPill(done: task.doneToday)
        }
        Text(task.details).font(.subheadline).foregroundColor(.secondary)
        
        if task.doneToday, let by = task.completedBy, let time = task.completedTime {
            Text("Completed by \(by) at \(time, formatter: Self.timeFormatter)")
                .font(.caption).foregroundColor(.secondary)
        } else if let due = task.dueTime {                       // << new line
            Text("Must be completed by \(due, formatter: Self.timeFormatter)")
                .font(.caption).foregroundColor(.red)            // red call-out
        }
    }}
    
    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter(); df.timeStyle = .short; return df }()
    
    private struct StatusPill: View {
        let done: Bool
        var body: some View {
            Text(done ? "Done" : "Pending")
                .font(.caption).bold().foregroundColor(.white)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(done ? Color.green : Color.yellow).cornerRadius(6)
        }
    }
}

private struct IssueCard: View { /* unchanged */ let issue: MaintenanceIssue
    var body: some View { CardBase(
        background: Color.red.opacity(0.12),
        shadow: Color.red.opacity(0.25)
    ) {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white).padding(4)
                .background(Color.red).clipShape(Circle())
            Text(issue.title).font(.headline)
        }
        Text(issue.description).font(.subheadline).foregroundColor(.secondary)
    }}
}

// MARK: - Shared Card Shell (unchanged) ----------------------------------------

private struct CardBase<Content: View>: View { /* unchanged */
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

// MARK: - Preview ---------------------------------------------------------------

#Preview { MaintenanceView() }
