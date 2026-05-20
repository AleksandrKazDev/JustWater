//
//  HistoryPeriodSummarySection.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HistoryPeriodSummarySection: View {
    
    // MARK: - Properties
    
    let title: String
    let points: [HistoryChartPoint]
    let labelProvider: (HistoryChartPoint) -> String
    
    // MARK: - Body
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                if points.isEmpty {
                    emptyState
                } else {
                    pointsList
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var emptyState: some View {
        Text("No data for selected period")
            .font(AppTypography.body)
            .foregroundStyle(AppColors.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
    }
    
    private var pointsList: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(points) { point in
                HStack {
                    Text(labelProvider(point))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Spacer()
                    
                    Text("\(point.amount) ml")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }
        }
    }
}
