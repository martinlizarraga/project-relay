//
//  InventoryView.swift
//  SOPHub
//
//  Created by Martin Lizarraga on 4/21/25.
//  Re-written by ChatGPT on 4/28/25 – multi-category mock data & color accents
//

import SwiftUI

// MARK: - Domain ----------------------------------------------------------------

enum ProductCategory: String, CaseIterable, Identifiable {
    case chairs  = "Chairs"
    case tables  = "Tables"
    case doors   = "Doors"
    
    var id: Self { self }
    
    /// Accent colour used for the quantity pill in this section
    var accent: Color {
        switch self {
        case .chairs: return .blue
        case .tables: return .orange
        case .doors:  return .purple
        }
    }
}

struct InventoryItem: Identifiable {
    let id = UUID()
    let category: ProductCategory
    let name: String
    let lastCount: Date
    let quantity: Int
}

// MARK: Mock data ---------------------------------------------------------------

private let sampleInventory: [InventoryItem] = [
    // Chairs (4)
    .init(category: .chairs, name: "Classic Wooden Chair",     lastCount: .daysAgo(2),  quantity: 24),
    .init(category: .chairs, name: "Modern Mesh Office Chair", lastCount: .daysAgo(7),  quantity: 9),
    .init(category: .chairs, name: "Stackable Plastic Chair",  lastCount: .daysAgo(1),  quantity: 120),
    .init(category: .chairs, name: "Luxury Leather Armchair",  lastCount: .daysAgo(14), quantity: 4),
    
    // Tables (3)
    .init(category: .tables, name: "Round Dining Table",       lastCount: .daysAgo(3),  quantity: 12),
    .init(category: .tables, name: "Folding Event Table",      lastCount: .daysAgo(10), quantity: 34),
    .init(category: .tables, name: "Glass Coffee Table",       lastCount: .daysAgo(21), quantity: 5),
    
    // Doors (2)
    .init(category: .doors,  name: "Solid Oak Door",           lastCount: .daysAgo(5),  quantity: 8),
    .init(category: .doors,  name: "Sliding Barn Door",        lastCount: .daysAgo(30), quantity: 2)
]

// MARK: - View ------------------------------------------------------------------

struct InventoryView: View {
    @State private var items = sampleInventory
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(ProductCategory.allCases) { category in
                        // Section header
                        Text(category.rawValue)
                            .font(.title2).bold()
                            .padding(.horizontal)
                        
                        // Cards
                        VStack(spacing: 12) {
                            ForEach(items.filter { $0.category == category }) { item in
                                InventoryCard(item: item, accent: category.accent)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO: present Add-Item flow
                        print("Add Item tapped")
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

// MARK: - Card -------------------------------------------------------------------

private struct InventoryCard: View {
    let item: InventoryItem
    let accent: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.name)
                    .font(.headline)
                
                Spacer()
                
                // Quantity pill — darker accent if stock is low (<10)
                Text("\(item.quantity)")
                    .font(.caption).bold()
                    .foregroundColor(.white)
                    .padding(6)
                    .background(item.quantity < 10 ? accent : accent.opacity(0.6))
                    .cornerRadius(6)
            }
            
            Text("Last counted: \(item.lastCount, formatter: Self.dateFormatter)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
}

// MARK: - Helpers ----------------------------------------------------------------

private extension Date {
    /// Convenience for mock data
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now)!
    }
}

// MARK: - Preview ----------------------------------------------------------------

#Preview {
    InventoryView()
}
