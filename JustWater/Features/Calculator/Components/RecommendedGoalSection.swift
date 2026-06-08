//
//  RecommendedGoalSection.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct RecommendedGoalSection: View {
    
    // MARK: - Properties
    
    let goal: Int
    let measurementUnit: MeasurementUnit
    let onUse: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        GlassCard {
            VStack(spacing: AppSpacing.md) {
                Text(String(localized: "Recommended Goal"))
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text(formattedGoal)
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                
                PrimaryButton(
                    title: String(localized: "Use Recommended Goal"),
                    systemImage: "checkmark"
                ) {
                    HapticService.success()
                    onUse()
                }
            }
        }
    }
    
    // MARK: - Private
    
    private var formattedGoal: String {
        MeasurementUnitFormatter()
            .string(
                fromMilliliters: goal,
                unit: measurementUnit
            )
    }
}
