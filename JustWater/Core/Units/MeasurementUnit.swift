//
//  MeasurementUnit.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import Foundation

enum MeasurementUnit: String, CaseIterable, Identifiable {
    
    case milliliters
    case fluidOunces
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .milliliters:
            return String(localized: "unit.milliliters")
        case .fluidOunces:
            return String(localized: "unit.fluid_ounces")
        }
    }
    
    var shortTitle: String {
        switch self {
        case .milliliters:
            return String(localized: "unit.milliliters.short")
        case .fluidOunces:
            return String(localized: "unit.fluid_ounces.short")
        }
    }
    
    var toggled: MeasurementUnit {
        switch self {
        case .milliliters:
            return .fluidOunces
        case .fluidOunces:
            return .milliliters
        }
    }
    
    static func defaultUnit(
        for locale: Locale = .current
    ) -> MeasurementUnit {
        if locale.region?.identifier == "US" {
            return .fluidOunces
        }
        
        return .milliliters
    }
    
}
