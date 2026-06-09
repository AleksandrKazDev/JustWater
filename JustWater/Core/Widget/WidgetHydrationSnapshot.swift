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
    
    var completionRate: Double {
        guard dailyGoal > 0 else { return 0 }
        
        return min(
            Double(consumedWater) / Double(dailyGoal),
            1
        )
    }
    
    static var empty: WidgetHydrationSnapshot {
        WidgetHydrationSnapshot(
            consumedWater: 0,
            dailyGoal: 2_000,
            measurementUnitRawValue: "milliliters",
            date: .now,
            updatedAt: .now
        )
    }
}
