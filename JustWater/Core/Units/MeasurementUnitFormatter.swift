//
//  MeasurementUnitFormatter.swift
//  JustWater
//
//  Created by сонный on 08.06.2026.
//

import Foundation

struct MeasurementUnitFormatter {
    
    private let locale: Locale
    
    init(locale: Locale = .current) {
        self.locale = locale
    }
    
    func string(
        fromMilliliters milliliters: Int,
        unit: MeasurementUnit
    ) -> String {
        let value = MeasurementUnitConverter.value(
            fromMilliliters: milliliters,
            unit: unit
        )
        
        let formattedValue = formattedNumber(
            value,
            unit: unit
        )
        
        return "\(formattedValue) \(unit.shortTitle)"
    }
    
    func inputString(
        fromMilliliters milliliters: Int,
        unit: MeasurementUnit
    ) -> String {
        let value = MeasurementUnitConverter.value(
            fromMilliliters: milliliters,
            unit: unit
        )
        
        return formattedNumber(
            value,
            unit: unit
        )
    }
    
    private func formattedNumber(
        _ value: Double,
        unit: MeasurementUnit
    ) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        
        switch unit {
        case .milliliters:
            formatter.maximumFractionDigits = 0
            formatter.minimumFractionDigits = 0
            
        case .fluidOunces:
            formatter.maximumFractionDigits = 1
            formatter.minimumFractionDigits = 0
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
