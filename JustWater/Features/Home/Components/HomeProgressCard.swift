//
//  HomeProgressCard.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HomeProgressCard: View {
    
    // MARK: - Properties
    
    let hydrationState: HydrationState
    
    // MARK: - Body
    
    var body: some View {
        GlassCard {
            VStack(spacing: AppSpacing.lg) {
                WaterProgressView(
                    progress: hydrationState.visualProgress,
                    percentage: Int(hydrationState.completionRate * 100)
                )
                
                VStack(spacing: AppSpacing.xs) {
                    Text("\(hydrationState.consumedWater) ml")
                        .font(AppTypography.largeTitle)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Text("of \(hydrationState.dailyGoal) ml")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
    }
}
