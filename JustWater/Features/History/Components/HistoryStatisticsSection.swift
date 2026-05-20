//
//  HistoryStatisticsSection.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HistoryStatisticsSection: View {
    
    // MARK: - Properties
    
    let statistics: HistoryStatistics
    let period: HistoryPeriod
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                HistoryStatisticCard(
                    title: "Total",
                    value: "\(statistics.totalAmount) ml"
                )
                
                HistoryStatisticCard(
                    title: averageTitle,
                    value: "\(statistics.averageAmount) ml"
                )
            }
            
            HStack(spacing: AppSpacing.md) {
                HistoryStatisticCard(
                    title: secondaryMetricTitle,
                    value: secondaryMetricValue
                )
                
                HistoryStatisticCard(
                    title: bestMetricTitle,
                    value: bestMetricValue
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var averageTitle: String {
        switch period {
        case .day:
            return "Average"
            
        case .week, .month:
            return "Daily Avg"
            
        case .year:
            return "Monthly Avg"
        }
    }
    
    private var secondaryMetricTitle: String {
        switch period {
        case .day:
            return "Entries"
            
        case .week, .month, .year:
            return "Goal Days"
        }
    }
    
    private var secondaryMetricValue: String {
        switch period {
        case .day:
            return "\(statistics.entriesCount)"
            
        case .week, .month, .year:
            return "\(statistics.goalReachedCount)"
        }
    }
    
    private var bestMetricTitle: String {
        switch period {
        case .day:
            return "Goal"
            
        case .week, .month:
            return "Best Day"
            
        case .year:
            return "Best Month"
        }
    }
    
    private var bestMetricValue: String {
        switch period {
        case .day:
            return "\(Int(statistics.completionRate * 100))%"
            
        case .week, .month, .year:
            return statistics.bestAmount > 0
            ? "\(statistics.bestAmount) ml"
            : "—"
        }
    }
}

private struct HistoryStatisticCard: View {
    
    // MARK: - Properties
    
    let title: String
    let value: String
    
    // MARK: - Body
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                
                Text(value)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
