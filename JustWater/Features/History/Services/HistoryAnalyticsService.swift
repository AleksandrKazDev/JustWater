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
        dailyGoal: Int,
        referenceDate: Date
        
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
                component: .day,
                referenceDate: referenceDate
            )
            
        case .month:
            return makeGroupedAnalytics(
                period: period,
                entries: entries,
                dailyGoal: dailyGoal,
                component: .day,
                referenceDate: referenceDate
            )
            
        case .year:
            return makeGroupedAnalytics(
                period: period,
                entries: entries,
                dailyGoal: dailyGoal,
                component: .month,
                referenceDate: referenceDate
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
            statistics: makeDayStatistics(
                entries: entries,
                dailyGoal: dailyGoal
            ),
            chartPoints: chartPoints,
            entries: entries,
            drinkBreakdown: makeDrinkBreakdown(from: entries)
        )
    }
    
    private static func makeGroupedAnalytics(
        period: HistoryPeriod,
        entries: [WaterEntry],
        dailyGoal: Int,
        component: Calendar.Component,
        referenceDate: Date
    ) -> HistoryAnalytics {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: entries) { entry in
            groupedDate(
                from: entry.date,
                component: component,
                calendar: calendar
            )
        }
        
        let dates = normalizedDates(
            for: period,
            referenceDate: referenceDate,
            calendar: calendar
        )
        
        let chartPoints = dates.map { date in
            let entriesForDate = grouped[date] ?? []
            
            return HistoryChartPoint(
                date: date,
                label: chartLabel(
                    for: date,
                    period: period
                ),
                amount: entriesForDate.reduce(0) { $0 + $1.amount }
            )
        }
        
        return HistoryAnalytics(
            period: period,
            statistics: makeGroupedStatistics(
                chartPoints: chartPoints,
                dailyGoal: dailyGoal
            ),
            chartPoints: chartPoints,
            entries: entries,
            drinkBreakdown: makeDrinkBreakdown(from: entries)
        )
    }
    
    private static func groupedDate(
        from date: Date,
        component: Calendar.Component,
        calendar: Calendar
    ) -> Date {
        switch component {
        case .month:
            let components = calendar.dateComponents(
                [.year, .month],
                from: date
            )
            
            return calendar.date(from: components) ?? date
            
        default:
            return calendar.startOfDay(for: date)
        }
    }
    
    private static func normalizedDates(
        for period: HistoryPeriod,
        referenceDate: Date,
        calendar: Calendar
    ) -> [Date] {
        switch period {
        case .day:
            return []
            
        case .week:
            guard let weekInterval = calendar.dateInterval(
                of: .weekOfYear,
                for: referenceDate
            ) else {
                return []
            }
            
            return (0..<7).compactMap { dayOffset in
                calendar.date(
                    byAdding: .day,
                    value: dayOffset,
                    to: weekInterval.start
                )
            }
            
        case .month:
            guard let monthInterval = calendar.dateInterval(
                of: .month,
                for: referenceDate
            ),
                  let range = calendar.range(
                    of: .day,
                    in: .month,
                    for: referenceDate
                  ) else {
                return []
            }
            
            return range.compactMap { day in
                calendar.date(
                    byAdding: .day,
                    value: day - 1,
                    to: monthInterval.start
                )
            }
            
        case .year:
            guard let yearInterval = calendar.dateInterval(
                of: .year,
                for: referenceDate
            ) else {
                return []
            }
            
            return (0..<12).compactMap { monthOffset in
                calendar.date(
                    byAdding: .month,
                    value: monthOffset,
                    to: yearInterval.start
                )
            }
        }
    }
    
    private static func chartLabel(
        for date: Date,
        period: HistoryPeriod
    ) -> String {
        switch period {
        case .day:
            return date.formatted(.dateTime.hour())
            
        case .week:
            return date.formatted(.dateTime.day())
            
        case .month:
            return date.formatted(.dateTime.day())
            
        case .year:
            return date.formatted(.dateTime.month(.abbreviated))
        }
    }
    
    private static func makeDayStatistics(
        entries: [WaterEntry],
        dailyGoal: Int
    ) -> HistoryStatistics {
        let totalAmount = entries.reduce(0) { $0 + $1.amount }
        let entriesCount = entries.count
        
        let averageAmount = entriesCount == 0
        ? 0
        : totalAmount / entriesCount
        
        let completionRate = dailyGoal > 0
        ? Double(totalAmount) / Double(dailyGoal)
        : 0
        
        return HistoryStatistics(
            totalAmount: totalAmount,
            averageAmount: averageAmount,
            completionRate: completionRate,
            entriesCount: entriesCount,
            goalReachedCount: completionRate >= 1 ? 1 : 0,
            bestAmount: totalAmount,
            bestLabel: nil
        )
    }
    
    private static func makeGroupedStatistics(
        chartPoints: [HistoryChartPoint],
        dailyGoal: Int
    ) -> HistoryStatistics {
        let totalAmount = chartPoints.reduce(0) {
            $0 + $1.amount
        }
        
        let periodsCount = chartPoints.count
        
        let averageAmount = periodsCount == 0
        ? 0
        : totalAmount / periodsCount
        
        let goalReachedCount = chartPoints.filter {
            $0.amount >= dailyGoal
        }.count
        
        let bestPoint = chartPoints.max {
            $0.amount < $1.amount
        }
        
        let completionRate = dailyGoal > 0
        ? Double(averageAmount) / Double(dailyGoal)
        : 0
        
        return HistoryStatistics(
            totalAmount: totalAmount,
            averageAmount: averageAmount,
            completionRate: completionRate,
            entriesCount: periodsCount,
            goalReachedCount: goalReachedCount,
            bestAmount: bestPoint?.amount ?? 0,
            bestLabel: bestPoint?.label
        )
    }
    
    private static func makeDrinkBreakdown(
        from entries: [WaterEntry]
    ) -> [DrinkBreakdownItem] {
        let grouped = Dictionary(grouping: entries) { entry in
            entry.drinkType
        }
        
        return grouped
            .map { drinkType, entries in
                DrinkBreakdownItem(
                    drinkType: drinkType,
                    amount: entries.reduce(0) { $0 + $1.amount }
                )
            }
            .filter { $0.amount > 0 }
            .sorted { lhs, rhs in
                lhs.amount > rhs.amount
            }
    }
}
