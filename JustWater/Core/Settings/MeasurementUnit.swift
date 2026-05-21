//
//  MeasurementUnit.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import Foundation

enum MeasurementUnit: String, CaseIterable, Identifiable {
    
    case milliliters
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .milliliters:
            return "Milliliters"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .milliliters:
            return "ml"
        }
    }
}
