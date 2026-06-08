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
    let measurementUnit: MeasurementUnit
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
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "chart.bar")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColors.secondaryText.opacity(0.7))
            
            Text("No data for selected period")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
    }
    
    private var pointsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                HStack {
                    Text(labelProvider(point))
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Spacer()
                    
                    Text(formattedAmount(point.amount))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .padding(.vertical, AppSpacing.sm)
                
                if index < points.count - 1 {
                    Divider()
                        .opacity(0.28)
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func formattedAmount(
        _ amount: Int
    ) -> String {
        MeasurementUnitFormatter()
            .string(
                fromMilliliters: amount,
                unit: measurementUnit
            )
    }
}
