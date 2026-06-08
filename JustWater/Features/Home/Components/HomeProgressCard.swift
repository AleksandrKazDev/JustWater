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
    let measurementUnit: MeasurementUnit
    
    // MARK: - Body
    
    var body: some View {
        GlassCard {
            VStack(spacing: AppSpacing.lg) {
                WaterProgressView(
                    progress: hydrationState.visualProgress,
                    percentage: Int(hydrationState.completionRate * 100)
                )
                
                VStack(spacing: AppSpacing.xs) {
                    Text(
                        formattedVolume(
                            hydrationState.consumedWater
                        )
                    )
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    
                    Text(
                        String(
                            format: String(localized: "of %@"),
                            formattedVolume(
                                hydrationState.dailyGoal
                            )
                        )
                    )
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func formattedVolume(
        _ milliliters: Int
    ) -> String {
        MeasurementUnitFormatter()
            .string(
                fromMilliliters: milliliters,
                unit: measurementUnit
            )
    }
}
