//
//  DrinkSummarySection.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct DrinkSummarySection: View {
    
    // MARK: - Properties
    
    let items: [DrinkBreakdownItem]
    
    // MARK: - Body
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Drink Summary")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                if items.isEmpty {
                    emptyState
                } else {
                    rows
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColors.secondaryText.opacity(0.7))
            
            Text("No drinks logged yet")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
    }
    
    private var rows: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                DrinkSummaryRow(item: item)
                    .padding(.vertical, AppSpacing.sm)
                
                if index < items.count - 1 {
                    Divider()
                        .opacity(0.28)
                }
            }
        }
    }
}

private struct DrinkSummaryRow: View {
    
    // MARK: - Properties
    
    let item: DrinkBreakdownItem
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            DrinkIconView(drinkType: item.drinkType)
            
            Text(item.drinkType.title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
            
            Spacer(minLength: AppSpacing.sm)
            
            Text("\(item.amount) ml")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
    }
}
