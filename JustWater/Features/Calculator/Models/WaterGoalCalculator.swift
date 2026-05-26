//
//  WaterGoalCalculator.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import Foundation

enum WaterGoalCalculator {
    
    // MARK: - Public Methods
    
    static func recommendedGoal(
        weight: Int,
        gender: Gender,
        activityLevel: ActivityLevel
    ) -> Int {
        let baseGoal = Double(weight) * 32
        
        let adjustedGoal = baseGoal * activityLevel.multiplier
        
        let finalGoal = adjustedGoal + Double(gender.additionalWater)
        
        let roundedGoal = finalGoal.rounded(toNearest: 50)
        
        return Int(
            min(max(roundedGoal, 1500), 5000)
        )
    }
}

// MARK: - Helpers

private extension Double {
    
    func rounded(toNearest step: Double) -> Double {
        (self / step).rounded() * step
    }
}
