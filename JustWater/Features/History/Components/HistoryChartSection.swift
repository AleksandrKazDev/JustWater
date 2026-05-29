//
//  HistoryChartSection.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI
import Charts

struct HistoryChartSection: View {
    
    // MARK: - Properties
    
    let analytics: HistoryAnalytics
    let dailyGoal: Int
    
    // MARK: - Body
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(chartTitle)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                if shouldShowGoalReference {
                    goalLegend
                }
                
                if analytics.chartPoints.isEmpty {
                    emptyState
                } else {
                    chart
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var goalLegend: some View {
        HStack(spacing: AppSpacing.xs) {
            Capsule()
                .fill(AppColors.primaryBlue.opacity(0.35))
                .frame(width: 22, height: 2)
            
            Text(String(localized: "history.chart.daily_goal"))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColors.secondaryText.opacity(0.7))
            
            Text(String(localized: "No data for selected period"))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 160)
    }
    
    private var chart: some View {
        Chart {
            ForEach(analytics.chartPoints) { point in
                switch analytics.period {
                case .day, .year:
                    BarMark(
                        x: .value("Period", point.label),
                        y: .value("Water", point.amount)
                    )
                    .foregroundStyle(barGradient)
                    .cornerRadius(5)
                    
                case .week, .month:
                    LineMark(
                        x: .value("Period", point.label),
                        y: .value("Water", point.amount)
                    )
                    .foregroundStyle(AppColors.primaryBlue)
                    .lineStyle(
                        StrokeStyle(
                            lineWidth: 3,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    
                    AreaMark(
                        x: .value("Period", point.label),
                        y: .value("Water", point.amount)
                    )
                    .foregroundStyle(areaGradient)
                }
            }
            
            if shouldShowGoalReference {
                RuleMark(
                    y: .value(
                        "Goal",
                        dailyGoal
                    )
                )
                .foregroundStyle(AppColors.primaryBlue.opacity(0.35))
                .lineStyle(
                    StrokeStyle(
                        lineWidth: 1.5,
                        dash: [6]
                    )
                )
            }
        }
        .frame(height: 180)
        .chartYScale(domain: chartYDomain)
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                    .foregroundStyle(chartGridColor)
                
                AxisTick()
                    .foregroundStyle(chartGridColor)
                
                AxisValueLabel()
                    .foregroundStyle(chartAxisLabelColor)
            }
        }
        .chartXAxis {
            chartXAxis
        }
    }
    
    // MARK: - Styling
    
    private var barGradient: LinearGradient {
        LinearGradient(
            colors: [
                AppColors.primaryBlue.opacity(0.72),
                AppColors.primaryBlue.opacity(0.92),
                AppColors.deepBlue.opacity(0.90)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [
                AppColors.primaryBlue.opacity(0.22),
                AppColors.primaryBlue.opacity(0.02)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var chartGridColor: Color {
        AppColors.secondaryText.opacity(0.18)
    }
    
    private var chartAxisLabelColor: Color {
        AppColors.secondaryText.opacity(0.86)
    }
    
    // MARK: - Helpers
    
    private var chartTitle: String {
        switch analytics.period {
        case .day:
            return String(localized: "history.chart.intake_by_time")
            
        case .week, .month, .year:
            return String(localized: "history.chart.consumption")
        }
    }
    
    private var shouldShowGoalReference: Bool {
        switch analytics.period {
        case .week, .month:
            return true
            
        case .day, .year:
            return false
        }
    }
    
    @AxisContentBuilder
    private var chartXAxis: some AxisContent {
        switch analytics.period {
        case .month:
            AxisMarks(
                values: monthAxisLabels
            ) { _ in
                AxisValueLabel()
                    .foregroundStyle(chartAxisLabelColor)
            }
            
        case .year:
            AxisMarks(
                values: yearAxisLabels
            ) { _ in
                AxisValueLabel()
                    .foregroundStyle(chartAxisLabelColor)
            }
            
        default:
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .foregroundStyle(chartAxisLabelColor)
            }
        }
    }
    
    private var monthAxisLabels: [String] {
        analytics.chartPoints
            .map(\.label)
            .filter { label in
                guard let day = Int(label) else {
                    return false
                }
                
                return day == 1 ||
                day == 5 ||
                day == 10 ||
                day == 15 ||
                day == 20 ||
                day == 25 ||
                day == 30
            }
    }
    
    private var yearAxisLabels: [String] {
        analytics.chartPoints
            .enumerated()
            .compactMap { index, point in
                index.isMultiple(of: 2) ? point.label : nil
            }
    }
    
    private var chartYDomain: ClosedRange<Int> {
        let maxAmount = analytics.chartPoints.map(\.amount).max() ?? 0
        
        switch analytics.period {
        case .day:
            let upperBound = max(
                500,
                roundedChartUpperBound(maxAmount)
            )
            
            return 0...upperBound
            
        case .week, .month:
            let upperBound = max(
                dailyGoal,
                roundedChartUpperBound(maxAmount)
            )
            
            return 0...upperBound
            
        case .year:
            let upperBound = max(
                500,
                roundedChartUpperBound(maxAmount)
            )
            
            return 0...upperBound
        }
    }
    
    private func roundedChartUpperBound(
        _ value: Int
    ) -> Int {
        guard value > 0 else { return 500 }
        
        let step = 500
        return ((value + step - 1) / step) * step
    }
}
