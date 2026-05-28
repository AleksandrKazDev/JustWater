//
//  ActivityLevel.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import Foundation

enum ActivityLevel: String, CaseIterable, Identifiable {
    case low
    case moderate
    case high
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .low:
            return String(localized: "activity.low.title")
            
        case .moderate:
            return String(localized: "activity.moderate.title")
            
        case .high:
            return String(localized: "activity.high.title")
        }
    }
    
    var multiplier: Double {
        switch self {
        case .low:
            return 1.0
            
        case .moderate:
            return 1.1
            
        case .high:
            return 1.2
        }
    }
    
    var description: String {
        switch self {
        case .low:
            return String(localized: "activity.low.description")
            
        case .moderate:
            return String(localized: "activity.moderate.description")
            
        case .high:
            return String(localized: "activity.high.description")
        }
    }
}
