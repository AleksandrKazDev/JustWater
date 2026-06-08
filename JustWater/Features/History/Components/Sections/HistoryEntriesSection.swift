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
    let measurementUnit: MeasurementUnit
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
            Text(String(localized: "Entries"))
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            Button {
                HapticService.selection()
                onAdd()
            } label: {
                Label(String(localized: "Add"), systemImage: "plus")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.primaryBlue)
                    .padding(.horizontal, AppSpacing.md)
                    .frame(height: 34)
                    .background {
                        Capsule()
                            .fill(AppColors.glassFill)
                            .background {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.30)
                            }
                    }
                    .overlay {
                        Capsule()
                            .stroke(
                                AppColors.glassStroke.opacity(0.20),
                                lineWidth: 1
                            )
                    }
            }
            .buttonStyle(
                PressableScaleButtonStyle(
                    scale: 0.96,
                    pressedBrightness: -0.02
                )
            )
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "drop")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColors.secondaryText.opacity(0.7))
            
            Text(String(localized: "No entries yet"))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
    }
    
    private var entriesList: some View {
        VStack(spacing: 0) {
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                HistoryEntryRow(
                    entry: entry,
                    measurementUnit: measurementUnit,
                    onEdit: onEdit,
                    onDelete: onDelete
                )
                .padding(.vertical, AppSpacing.sm)
                .transition(
                    .asymmetric(
                        insertion: .opacity,
                        removal: .opacity.combined(
                            with: .scale(scale: 0.96)
                        )
                    )
                )
                
                if index < entries.count - 1 {
                    Divider()
                        .opacity(0.28)
                }
            }
        }
        .animation(
            .spring(response: 0.45, dampingFraction: 0.9),
            value: entries.map(\.id)
        )
    }
}
