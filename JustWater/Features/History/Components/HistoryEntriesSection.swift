//
//  HistoryEntriesSection.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HistoryEntriesSection: View {
    
    // MARK: - Properties
    
    let entries: [WaterEntry]
    let onAdd: () -> Void
    let onEdit: (WaterEntry) -> Void
    let onDelete: (WaterEntry) -> Void
    
    // MARK: - Body
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                header
                
                if entries.isEmpty {
                    emptyState
                } else {
                    entriesList
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var header: some View {
        HStack {
            Text("Entries")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            Button {
                onAdd()
            } label: {
                Label("Add", systemImage: "plus")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.primaryBlue)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background {
                        Capsule()
                            .fill(AppColors.lightBlue.opacity(0.28))
                    }
            }
            .buttonStyle(.plain)
        }
    }
    
    private var emptyState: some View {
        Text("No entries yet")
            .font(AppTypography.body)
            .foregroundStyle(AppColors.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
    }
    
    private var entriesList: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(entries) { entry in
                HistoryEntryRow(
                    entry: entry,
                    onEdit: onEdit,
                    onDelete: onDelete
                )
                .transition(
                    .asymmetric(
                        insertion: .opacity,
                        removal: .opacity.combined(
                            with: .scale(scale: 0.96)
                        )
                    )
                )
            }
        }
        .animation(
            .spring(response: 0.45, dampingFraction: 0.9),
            value: entries.map(\.id)
        )
    }
}
