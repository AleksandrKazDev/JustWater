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
                Text(String(localized: "Recommended Goal"))
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text(
                    String(
                        format: String(localized: "%lld ml"),
                        goal
                    )
                )
                .font(AppTypography.largeTitle)
                .foregroundStyle(AppColors.primaryText)
                
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
}
