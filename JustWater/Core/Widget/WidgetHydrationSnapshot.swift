//
//  WidgetHydrationSnapshot.swift
//  JustWater
//
//  Created by сонный on 09.06.2026.
//

import Foundation

struct WidgetHydrationSnapshot: Codable {
    
    let consumedWater: Int
    let dailyGoal: Int
    let measurementUnitRawValue: String
    let date: Date
    let updatedAt: Date
    
    var rawCompletionRate: Double {
        guard dailyGoal > 0 else { return 0 }
        
        return Double(consumedWater) / Double(dailyGoal)
    }
    
    var cappedCompletionRate: Double {
        min(rawCompletionRate, 1)
    }
    
    var percentage: Int {
        Int(rawCompletionRate * 100)
    }
    
    var remainingWater: Int {
        max(dailyGoal - consumedWater, 0)
    }

    var isGoalCompleted: Bool {
        consumedWater >= dailyGoal
    }
    
    func isForToday(
        calendar: Calendar = .current
    ) -> Bool {
        calendar.isDateInToday(date)
    }
    
    func normalizedForToday(
        calendar: Calendar = .current
    ) -> WidgetHydrationSnapshot {
        guard isForToday(calendar: calendar) else {
            return WidgetHydrationSnapshot(
                consumedWater: 0,
                dailyGoal: dailyGoal,
                measurementUnitRawValue: measurementUnitRawValue,
                date: .now,
                updatedAt: .now
            )
        }
        
        return self
    }
    
    static var empty: WidgetHydrationSnapshot {
        WidgetHydrationSnapshot(
            consumedWater: 0,
            dailyGoal: 2_000,
            measurementUnitRawValue: MeasurementUnit.milliliters.rawValue,
            date: .now,
            updatedAt: .now
        )
    }
}
