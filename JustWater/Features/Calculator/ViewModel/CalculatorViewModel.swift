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
}
