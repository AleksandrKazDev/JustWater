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
                    VStack(spacing: AppSpacing.md) {
                        ForEach(items) { item in
                            DrinkSummaryRow(item: item)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var emptyState: some View {
        Text("No drinks logged yet")
            .font(AppTypography.body)
            .foregroundStyle(AppColors.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
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
            
            Spacer()
            
            Text("\(item.amount) ml")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
}
