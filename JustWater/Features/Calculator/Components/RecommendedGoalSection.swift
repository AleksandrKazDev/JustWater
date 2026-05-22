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
    let onUse: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        GlassCard {
            VStack(spacing: AppSpacing.md) {
                Text("Recommended Goal")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("\(goal) ml")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primaryText)
                
                PrimaryButton(
                    title: "Use Recommended Goal",
                    systemImage: "checkmark"
                ) {
                    HapticService.success()
                    onUse()
                }
            }
        }
    }
}
