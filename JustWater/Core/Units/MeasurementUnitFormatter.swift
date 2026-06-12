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
        switch unit {
        case .milliliters:
            return value.formatted(
                .number
                    .locale(locale)
                    .precision(.fractionLength(0))
            )
            
        case .fluidOunces:
            return value.formatted(
                .number
                    .locale(locale)
                    .precision(.fractionLength(0...1))
            )
        }
    }
}
