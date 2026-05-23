//
//  HistoryEntryRow.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HistoryEntryRow: View {
    
    // MARK: - Properties
    
    let entry: WaterEntry
    let onEdit: (WaterEntry) -> Void
    let onDelete: (WaterEntry) -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            editButton
            
            deleteButton
        }
    }
    
    // MARK: - Components
    
    private var editButton: some View {
        Button {
            HapticService.selection()
            onEdit(entry)
        } label: {
            HStack(spacing: AppSpacing.sm) {
                drinkIcon
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.amount) ml")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                    
                    Text(entry.drinkType.title)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                }
                
                Spacer(minLength: AppSpacing.sm)
                
                Text(entry.date, style: .time)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(
            PressableScaleButtonStyle(
                scale: 0.985,
                pressedBrightness: -0.015
            )
        )
    }
    
    private var drinkIcon: some View {
        DrinkIconView(drinkType: entry.drinkType)
    }
    
    private var deleteButton: some View {
        Button {
            HapticService.selection()
            
            withAnimation(
                .spring(
                    response: 0.45,
                    dampingFraction: 0.9
                )
            ) {
                onDelete(entry)
            }
        } label: {
            Image(systemName: "trash")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.secondaryText)
                .frame(width: 36, height: 36)
                .background {
                    Circle()
                        .fill(AppColors.glassFill.opacity(0.45))
                }
                .overlay {
                    Circle()
                        .stroke(
                            AppColors.glassStroke.opacity(0.18),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(
            PressableScaleButtonStyle(
                scale: 0.94,
                pressedBrightness: -0.02
            )
        )
        .accessibilityLabel("Delete entry")
    }
}
