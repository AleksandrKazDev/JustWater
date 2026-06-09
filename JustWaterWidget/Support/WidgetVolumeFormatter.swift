//
//  WidgetVolumeFormatter.swift
//  JustWaterWidgetExtension
//
//  Created by сонный on 10.06.2026.
//

import Foundation

struct WidgetVolumeFormatter {
    
    // MARK: - Public Methods
    
    func string(
        fromMilliliters milliliters: Int,
        unit: MeasurementUnit
    ) -> String {
        switch unit {
        case .milliliters:
            return millilitersString(
                fromMilliliters: milliliters
            )
            
        case .fluidOunces:
            return fluidOuncesString(
                fromMilliliters: milliliters
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func millilitersString(
        fromMilliliters milliliters: Int
    ) -> String {
        let value = MeasurementUnitFormatter()
            .inputString(
                fromMilliliters: milliliters,
                unit: .milliliters
            )
        
        return "\(value) ml"
    }
    
    private func fluidOuncesString(
        fromMilliliters milliliters: Int
    ) -> String {
        let value = MeasurementUnitConverter.value(
            fromMilliliters: milliliters,
            unit: .fluidOunces
        )
        
        return "\(Int(value.rounded())) fl oz"
    }
}
