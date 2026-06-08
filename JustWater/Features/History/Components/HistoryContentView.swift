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
    let currentStreak: Int
    let measurementUnit: MeasurementUnit
    
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
                period: analytics.period,
                currentStreak: currentStreak,
                measurementUnit: measurementUnit
            )
            
            HistoryChartSection(
                analytics: analytics,
                dailyGoal: dailyGoal,
                measurementUnit: measurementUnit
            )
            
            HistoryEntriesSection(
                entries: analytics.entries,
                measurementUnit: measurementUnit,
                onAdd: onAddEntry,
                onEdit: onEditEntry,
                onDelete: onDeleteEntry
            )
            
            DrinkSummarySection(
                items: analytics.drinkBreakdown,
                measurementUnit: measurementUnit
            )
        }
    }
    
    private var weekContent: some View {
        Group {
            HistoryStatisticsSection(
                statistics: analytics.statistics,
                period: analytics.period,
                currentStreak: currentStreak,
                measurementUnit: measurementUnit
            )
            
            HistoryChartSection(
                analytics: analytics,
                dailyGoal: dailyGoal,
                measurementUnit: measurementUnit
            )
            
            HistoryPeriodSummarySection(
                title: String(localized: "Daily Summary"),
                points: analytics.chartPoints,
                measurementUnit: measurementUnit,
                labelProvider: weekSummaryLabel
            )
            
            DrinkSummarySection(
                items: analytics.drinkBreakdown,
                measurementUnit: measurementUnit
            )
        }
    }
    
    private var monthContent: some View {
        Group {
            HistoryStatisticsSection(
                statistics: analytics.statistics,
                period: analytics.period,
                currentStreak: currentStreak,
                measurementUnit: measurementUnit
            )
            
            HistoryChartSection(
                analytics: analytics,
                dailyGoal: dailyGoal,
                measurementUnit: measurementUnit
            )
            
            DrinkSummarySection(
                items: analytics.drinkBreakdown,
                measurementUnit: measurementUnit
            )
        }
    }
    
    private var yearContent: some View {
        Group {
            HistoryStatisticsSection(
                statistics: analytics.statistics,
                period: analytics.period,
                currentStreak: currentStreak,
                measurementUnit: measurementUnit
            )
            
            HistoryChartSection(
                analytics: analytics,
                dailyGoal: dailyGoal,
                measurementUnit: measurementUnit
            )
            
            HistoryPeriodSummarySection(
                title: String(localized: "Monthly Summary"),
                points: analytics.chartPoints,
                measurementUnit: measurementUnit,
                labelProvider: { $0.label }
            )
            
            DrinkSummarySection(
                items: analytics.drinkBreakdown,
                measurementUnit: measurementUnit
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
