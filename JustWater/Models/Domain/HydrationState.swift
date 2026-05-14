//
//  HydrationState.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation

struct HydrationState {
    
    let dailyGoal: Int
    var entries: [WaterEntry]
    
    var consumedWater: Int {
        entries.reduce(0) { $0 + $1.amount }
    }
    
    var progress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(consumedWater) / Double(dailyGoal), 1)
    }
    
    var remainingWater: Int {
        max(dailyGoal - consumedWater, 0)
    }
}
