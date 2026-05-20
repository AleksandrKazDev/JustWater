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
            onEdit(entry)
        } label: {
            HStack(spacing: AppSpacing.sm) {
                drinkIcon
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.amount) ml")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Text(entry.drinkType.title)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                Spacer()
                
                Text(entry.date, style: .time)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var drinkIcon: some View {
        DrinkIconView(drinkType: entry.drinkType)
    }
    
    private var deleteButton: some View {
        Button {
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
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.secondaryText)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
    }
}
