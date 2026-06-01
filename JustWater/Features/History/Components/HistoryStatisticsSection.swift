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
    let currentStreak: Int
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                HistoryStatisticCard(
                    title: String(localized: "history.stat.total"),
                    value: formattedAmount(statistics.totalAmount)
                )
                
                HistoryStatisticCard(
                    title: primarySecondaryMetricTitle,
                    value: primarySecondaryMetricValue
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
    
    private var primarySecondaryMetricTitle: String {
        switch period {
        case .day:
            return String(localized: "history.stat.streak")
            
        case .week, .month:
            return String(localized: "history.stat.daily_avg")
            
        case .year:
            return String(localized: "history.stat.monthly_avg")
        }
    }
    
    private var primarySecondaryMetricValue: String {
        switch period {
        case .day:
            return streakValue
            
        case .week, .month, .year:
            return formattedAmount(
                statistics.averageAmount
            )
        }
    }
    
    private var secondaryMetricTitle: String {
        switch period {
        case .day:
            return String(localized: "history.stat.entries")
            
        case .week, .month, .year:
            return String(localized: "history.stat.goal_days")
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
            return String(localized: "history.stat.goal")
            
        case .week, .month:
            return String(localized: "history.stat.highest_day")
            
        case .year:
            return String(localized: "history.stat.highest_month")
        }
    }
    
    private var bestMetricValue: String {
        switch period {
        case .day:
            return "\(Int(statistics.completionRate * 100))%"
            
        case .week, .month, .year:
            return statistics.bestAmount > 0
            ? formattedAmount(statistics.bestAmount)
            : "—"
        }
    }
    
    private var streakValue: String {
        String(
            format: String(localized: "history.stat.streak_days"),
            currentStreak
        )
    }
    
    // MARK: - Private Methods
    
    private func formattedAmount(
        _ amount: Int
    ) -> String {
        String(
            format: String(localized: "%lld ml"),
            amount
        )
    }
}

private struct HistoryStatisticCard: View {
    
    // MARK: - Properties
    
    let title: String
    let value: String
    
    // MARK: - Body
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                
                Text(value)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 68, alignment: .center)
        }
    }
}
