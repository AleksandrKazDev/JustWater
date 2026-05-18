//
//  HistoryAnalyticsService.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import Foundation

enum HistoryAnalyticsService {
    
    // MARK: - Public Methods
    
    static func makeAnalytics(
        period: HistoryPeriod,
        entries: [WaterEntry],
        dailyGoal: Int
    ) -> HistoryAnalytics {
        switch period {
        case .day:
            return makeDayAnalytics(
                entries: entries,
                dailyGoal: dailyGoal
            )
            
        case .week:
            return makeGroupedAnalytics(
                period: period,
                entries: entries,
                dailyGoal: dailyGoal,
                component: .day
            )
            
        case .month:
            return makeGroupedAnalytics(
                period: period,
                entries: entries,
                dailyGoal: dailyGoal,
                component: .day
            )
            
        case .year:
            return makeGroupedAnalytics(
                period: period,
                entries: entries,
                dailyGoal: dailyGoal,
                component: .month
            )
        }
    }
    
    // MARK: - Private Methods
    
    private static func makeDayAnalytics(
        entries: [WaterEntry],
        dailyGoal: Int
    ) -> HistoryAnalytics {
        let calendar = Calendar.current
        
        let chartPoints = Dictionary(grouping: entries) { entry in
            calendar.component(.hour, from: entry.date)
        }
        .map { hour, entries in
            HistoryChartPoint(
                date: entries.first?.date ?? Date(),
                label: "\(hour):00",
                amount: entries.reduce(0) { $0 + $1.amount }
            )
        }
        .sorted { $0.date < $1.date }
        
        return HistoryAnalytics(
            period: .day,
            statistics: makeStatistics(
                entries: entries,
                dailyGoal: dailyGoal
            ),
            chartPoints: chartPoints,
            entries: entries
        )
    }
    
    private static func makeGroupedAnalytics(
        period: HistoryPeriod,
        entries: [WaterEntry],
        dailyGoal: Int,
        component: Calendar.Component
    ) -> HistoryAnalytics {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: entries) { entry in
            groupedDate(
                from: entry.date,
                component: component,
                calendar: calendar
            )
        }
        
        let chartPoints = grouped
            .map { date, entries in
                HistoryChartPoint(
                    date: date,
                    label: date.formatted(.dateTime.day().month(.abbreviated)),
                    amount: entries.reduce(0) { $0 + $1.amount }
                )
            }
            .sorted { $0.date < $1.date }
        
        return HistoryAnalytics(
            period: period,
            statistics: makeStatistics(
                entries: entries,
                dailyGoal: dailyGoal
            ),
            chartPoints: chartPoints,
            entries: entries
        )
    }
    
    private static func groupedDate(
        from date: Date,
        component: Calendar.Component,
        calendar: Calendar
    ) -> Date {
        switch component {
        case .month:
            let components = calendar.dateComponents([.year, .month], from: date)
            return calendar.date(from: components) ?? date
            
        default:
            return calendar.startOfDay(for: date)
        }
    }
    
    private static func makeStatistics(
        entries: [WaterEntry],
        dailyGoal: Int
    ) -> HistoryStatistics {
        let totalAmount = entries.reduce(0) { $0 + $1.amount }
        let entriesCount = entries.count
        
        let averageAmount = entriesCount == 0
        ? 0
        : totalAmount / entriesCount
        
        let completionRate = dailyGoal > 0
        ? min(Double(totalAmount) / Double(dailyGoal), 1)
        : 0
        
        return HistoryStatistics(
            totalAmount: totalAmount,
            averageAmount: averageAmount,
            completionRate: completionRate,
            entriesCount: entriesCount
        )
    }
}
