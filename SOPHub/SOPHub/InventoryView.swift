//
//  InventoryView.swift
//  SOPHub
//  Updated 4/30/25 – adds "Mark Out of Stock" toggle, renames buttons, swaps labels
//

import SwiftUI

// MARK: - Domain --------------------------------------------------------------

enum InventoryCategory: String, CaseIterable, Identifiable {
    case beverages = "Beverages"
    case packaging = "Packaging"
    case cleaning  = "Cleaning"
    case merch     = "Merchandise"

    var id: Self { self }

    /// Accent colour used for the category header
    var accent: Color {
        switch self {
        case .beverages:  return .blue
        case .packaging:  return .orange
        case .cleaning:   return .green
        case .merch:      return .purple
        }
    }
}

struct InventoryItem: Identifiable, Hashable {
    let id: UUID = UUID()
    var category: InventoryCategory
    var name: String
    var sku: String
    var lastOrdered: Date
    var outOfStock: Bool = false
}

// MARK: - Mock Data -----------------------------------------------------------

private var sampleInventory: [InventoryItem] = [
    .init(category: .beverages,  name: "Cola 12 oz Can",          sku: "BEV‑COLA‑12", lastOrdered: .daysAgo(3)),
    .init(category: .beverages,  name: "Sparkling Water 1 L",      sku: "BEV‑SPRK‑1L", lastOrdered: .daysAgo(8)),
    .init(category: .packaging,  name: "Small Paper Bag",          sku: "PKG‑BAG‑S",   lastOrdered: .daysAgo(1)),
    .init(category: .packaging,  name: "Corrugated Box 12×12×6",  sku: "PKG‑BOX‑12126", lastOrdered: .daysAgo(10)),
    .init(category: .cleaning,   name: "Surface Disinfectant",    sku: "CLN‑SPRAY",  lastOrdered: .daysAgo(4)),
    .init(category: .merch,      name: "Logo T‑Shirt (M)",        sku: "MRCH‑TSHIRT‑M", lastOrdered: .daysAgo(14))
]

// MARK: - View ---------------------------------------------------------------

struct InventoryView: View {
    @State private var items   = sampleInventory
    @State private var tickets = [InventoryTicket]()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(InventoryCategory.allCases) { cat in
                        categorySection(for: cat)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Inventory")
        }
    }

    // MARK: Section Builder --------------------------------------------------

    @ViewBuilder private func categorySection(for category: InventoryCategory) -> some View {
        let catItems = $items.filter { $0.category.wrappedValue == category }

        if !catItems.isEmpty {
            Text(category.rawValue)
                .font(.title2).bold()
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(catItems) { $item in
                    InventoryCard(item: $item) { ticketTitle in
                        let newTicket = InventoryTicket(title: ticketTitle, description: "Raised from Inventory")
                        tickets.append(newTicket)
                        print("[DEBUG] Created inventory ticket → \(ticketTitle)")
                    }
                }
            }
        }
    }
}

// MARK: - Ticket Stub ---------------------------------------------------------

struct InventoryTicket: Identifiable, Hashable {
    let id: UUID = UUID()
    var title: String
    var description: String
    var createdAt: Date = .now
}

// MARK: - Card ----------------------------------------------------------------

private struct InventoryCard: View {
    @Binding var item: InventoryItem
    var createTicket: (String) -> Void

    var body: some View {
        CardBase(background: item.outOfStock ? Color.red.opacity(0.15) : Color(UIColor.secondarySystemBackground),
                 shadow: item.outOfStock ? Color.red.opacity(0.25) : Color.gray.opacity(0.3)) {

            // Header row ----------------------------------------------------
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name).font(.headline)
                    Text("SKU: \(item.sku)").font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                stockStatusPill
            }

            // Footer --------------------------------------------------------
            Text("Last ordered: \(item.lastOrdered, formatter: Self.dateFormatter)")
                .font(.subheadline).foregroundColor(.secondary)

            // Action buttons ------------------------------------------------
            HStack(spacing: 16) {
                Button(action: toggleStock) {
                    Label(item.outOfStock ? "Mark In Stock" : "Mark Out of Stock",
                          systemImage: item.outOfStock ? "arrow.uturn.backward" : "exclamationmark.triangle")
                }
                .buttonStyle(.borderedProminent)
                .tint(item.outOfStock ? .green : .red)

                Button {
                    createTicket("Issue with \(item.name)")
                } label: {
                    Label("Create Ticket", systemImage: "plus.rectangle.on.rectangle")
                }
                .buttonStyle(.bordered)

                Button(action: openProductInfo) {
                    Label("Product Information", systemImage: "doc.text")
                }
                .buttonStyle(.bordered)
            }
            .font(.caption)
        }
        .onAppear { print("[DEBUG] InventoryCard – \(item.name) outOfStock: \(item.outOfStock)") }
    }

    // MARK: Helpers ----------------------------------------------------------

    private func toggleStock() {
        item.outOfStock.toggle()
        print("[DEBUG] Toggled outOfStock for \(item.name) → \(item.outOfStock)")
    }

    private func openProductInfo() {
        // Placeholder – Navigate to SOP detail later
        print("[DEBUG] Open product Info for \(item.name)")
    }

    private var stockStatusPill: some View {
        Text(item.outOfStock ? "Out of Stock" : "In Stock")
            .font(.caption).bold().foregroundColor(.white)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(item.outOfStock ? Color.red : Color.green)
            .cornerRadius(6)
    }

    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter(); df.dateStyle = .medium; return df }()
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
            .padding(.horizontal)
    }
}

// MARK: - Mock Date Helper ----------------------------------------------------

private extension Date {
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now)! }
}

// MARK: - Preview -------------------------------------------------------------

#Preview { InventoryView() }
