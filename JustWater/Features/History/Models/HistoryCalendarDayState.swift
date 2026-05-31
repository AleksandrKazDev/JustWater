//
//  HistoryCalendarDayState.swift
//  JustWater
//
//  Created by сонный on 31.05.2026.
//

import Foundation

struct HistoryCalendarDayState: Equatable {
    
    // MARK: - Properties
    
    let totalAmount: Int
    let goal: Int
    
    // MARK: - Computed Properties
    
    var progress: Double {
        guard goal > 0 else {
            return 0
        }
        
        return min(
            Double(totalAmount) / Double(goal),
            1
        )
    }
    
    var hasEntries: Bool {
        totalAmount > 0
    }
    
    var isGoalReached: Bool {
        totalAmount >= goal
    }
}
