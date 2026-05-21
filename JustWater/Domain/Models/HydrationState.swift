//
//  HydrationState.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation

struct HydrationState {
    
    var dailyGoal: Int
    var entries: [WaterEntry]
    
    var consumedWater: Int {
        entries.reduce(0) { $0 + $1.amount }
    }
    
    /// Реальный процент выполнения дневной цели.
    /// Может быть больше 1.0, например 1.35 = 135%.
    var completionRate: Double {
        guard dailyGoal > 0 else { return 0 }
        
        return Double(consumedWater) / Double(dailyGoal)
    }
    
    /// Визуальный прогресс для резервуара воды.
    /// Ограничен 100%, чтобы UI не ломался после перевыполнения цели.
    var visualProgress: Double {
        min(completionRate, 1)
    }
    
    var remainingWater: Int {
        max(dailyGoal - consumedWater, 0)
    }
}
