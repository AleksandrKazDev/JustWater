//
//  CalculatorViewModel.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import Foundation

@Observable
final class CalculatorViewModel {
    
    // MARK: - Input
    
    var weightText = ""
    private let maximumWeight = 250
    var gender: Gender = .male
    var activityLevel: ActivityLevel = .moderate
    
    var customGoalText = ""
    private let minimumCustomGoal = 1
    private let maximumCustomGoal = 10000
    var customGoal: Int? {
        guard let goal = Int(customGoalText),
              goal >= minimumCustomGoal,
              goal <= maximumCustomGoal else {
            return nil
        }
        
        return goal
    }
    // MARK: - Output
    
    var recommendedGoal: Int?
    
    // MARK: - Public Methods
    
    func calculateGoal() {
        guard let weight = Int(weightText),
              weight > 0 else {
            recommendedGoal = nil
            return
        }
        
        recommendedGoal = WaterGoalCalculator.recommendedGoal(
            weight: weight,
            gender: gender,
            activityLevel: activityLevel
        )
    }
    
    func updateWeightText(_ newValue: String) {
        let digitsOnly = newValue.filter(\.isNumber)
        
        if let weight = Int(digitsOnly), weight > maximumWeight {
            weightText = "\(maximumWeight)"
        } else {
            weightText = digitsOnly
        }
        
        recommendedGoal = nil
    }
    
    func updateCustomGoalText(_ newValue: String) {
        let digitsOnly = newValue.filter(\.isNumber)
        
        guard let goal = Int(digitsOnly) else {
            customGoalText = digitsOnly
            return
        }
        
        if goal > maximumCustomGoal {
            customGoalText = "\(maximumCustomGoal)"
        } else {
            customGoalText = digitsOnly
        }
    }
}
