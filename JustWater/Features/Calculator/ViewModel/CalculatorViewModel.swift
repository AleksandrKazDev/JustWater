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
    private let maximumCustomGoalMilliliters = 10_000
    private let maximumCustomGoalFluidOunces = 338
    
    private(set) var measurementUnit = AppSettingsStorage.measurementUnit
    
    var customGoal: Int? {
        guard let inputGoal = decimalValue(from: customGoalText),
              inputGoal >= Double(minimumCustomGoal),
              inputGoal <= Double(maximumCustomGoalInput) else {
            return nil
        }
        
        return MeasurementUnitConverter.milliliters(
            from: inputGoal,
            unit: measurementUnit
        )
    }
    
    var maximumCustomGoalInput: Int {
        switch measurementUnit {
        case .milliliters:
            return maximumCustomGoalMilliliters
            
        case .fluidOunces:
            return maximumCustomGoalFluidOunces
        }
    }
    
    // MARK: - Output
    
    var recommendedGoal: Int?
    
    // MARK: - Public Methods
    
    func reloadSettings() {
        measurementUnit = AppSettingsStorage.measurementUnit
    }
    
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
        switch measurementUnit {
        case .milliliters:
            updateIntegerCustomGoalText(newValue)
            
        case .fluidOunces:
            updateDecimalCustomGoalText(newValue)
        }
    }
    
    func selectGender(_ gender: Gender) {
        self.gender = gender
        recommendedGoal = nil
    }
    
    func selectActivityLevel(_ activityLevel: ActivityLevel) {
        self.activityLevel = activityLevel
        recommendedGoal = nil
    }
    
    // MARK: - Private Methods
    
    private func updateIntegerCustomGoalText(_ newValue: String) {
        let digitsOnly = newValue.filter(\.isNumber)
        
        guard let goal = Int(digitsOnly) else {
            customGoalText = digitsOnly
            return
        }
        
        if goal > maximumCustomGoalInput {
            customGoalText = "\(maximumCustomGoalInput)"
        } else {
            customGoalText = digitsOnly
        }
    }
    
    private func updateDecimalCustomGoalText(_ newValue: String) {
        var result = ""
        var hasSeparator = false
        
        for character in newValue {
            if character.isNumber {
                result.append(character)
            } else if character == "." || character == "," {
                guard !hasSeparator else { continue }
                
                result.append(character)
                hasSeparator = true
            }
        }
        
        guard let goal = decimalValue(from: result) else {
            customGoalText = result
            return
        }
        
        if goal > Double(maximumCustomGoalInput) {
            customGoalText = "\(maximumCustomGoalInput)"
        } else {
            customGoalText = result
        }
    }
    
    private func decimalValue(from text: String) -> Double? {
        let normalizedText = text
            .replacingOccurrences(of: ",", with: ".")
        
        return Double(normalizedText)
    }
}
