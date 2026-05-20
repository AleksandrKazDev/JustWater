//
//  HistoryContentView.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HistoryContentView: View {
    
    // MARK: - Properties
    
    let analytics: HistoryAnalytics
    let dailyGoal: Int
    
    let onAddEntry: () -> Void
    let onEditEntry: (WaterEntry) -> Void
    let onDeleteEntry: (WaterEntry) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            switch analytics.period {
            case .day:
                dayContent
                
            case .week:
                weekContent
                
            case .month:
                monthContent
                
            case .year:
                yearContent
            }
        }
    }
    
    // MARK: - Content
    
    private var dayContent: some View {
        Group {
            HistoryStatisticsSection(
                statistics: analytics.statistics,
                period: analytics.period
            )
            
            HistoryChartSection(
                analytics: analytics,
                dailyGoal: dailyGoal
            )
            
            HistoryEntriesSection(
                entries: analytics.entries,
                onAdd: onAddEntry,
                onEdit: onEditEntry,
                onDelete: onDeleteEntry
            )
            
            DrinkSummarySection(
                items: analytics.drinkBreakdown
            )
        }
    }
    
    private var weekContent: some View {
        Group {
            HistoryStatisticsSection(
                statistics: analytics.statistics,
                period: analytics.period
            )
            
            HistoryChartSection(
                analytics: analytics,
                dailyGoal: dailyGoal
            )
            
            HistoryPeriodSummarySection(
                title: "Daily Summary",
                points: analytics.chartPoints,
                labelProvider: weekSummaryLabel
            )
            
            DrinkSummarySection(
                items: analytics.drinkBreakdown
            )
        }
    }
    
    private var monthContent: some View {
        Group {
            HistoryStatisticsSection(
                statistics: analytics.statistics,
                period: analytics.period
            )
            
            HistoryChartSection(
                analytics: analytics,
                dailyGoal: dailyGoal
            )
            
            DrinkSummarySection(
                items: analytics.drinkBreakdown
            )
        }
    }
    
    private var yearContent: some View {
        Group {
            HistoryStatisticsSection(
                statistics: analytics.statistics,
                period: analytics.period
            )
            
            HistoryChartSection(
                analytics: analytics,
                dailyGoal: dailyGoal
            )
            
            HistoryPeriodSummarySection(
                title: "Monthly Summary",
                points: analytics.chartPoints,
                labelProvider: { $0.label }
            )
            
            DrinkSummarySection(
                items: analytics.drinkBreakdown
            )
        }
    }
    
    // MARK: - Helpers
    
    private func weekSummaryLabel(
        for point: HistoryChartPoint
    ) -> String {
        let weekday = point.date.formatted(
            .dateTime.weekday(.abbreviated)
        )
        
        let day = point.date.formatted(
            .dateTime.day()
        )
        
        return "\(weekday) \(day)"
    }
}
