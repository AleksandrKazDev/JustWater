//
//  MeasurementUnitConverter.swift
//  JustWater
//
//  Created by сонный on 08.06.2026.
//

import Foundation

enum MeasurementUnitConverter {
    
    private static let millilitersPerFluidOunce = 29.5735295625
    
    static func milliliters(
        from value: Double,
        unit: MeasurementUnit
    ) -> Int {
        switch unit {
        case .milliliters:
            return Int(value.rounded())
            
        case .fluidOunces:
            return Int((value * millilitersPerFluidOunce).rounded())
        }
    }
    
    static func value(
        fromMilliliters milliliters: Int,
        unit: MeasurementUnit
    ) -> Double {
        switch unit {
        case .milliliters:
            return Double(milliliters)
            
        case .fluidOunces:
            return Double(milliliters) / millilitersPerFluidOunce
        }
    }
}
