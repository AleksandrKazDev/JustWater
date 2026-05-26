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
            return "Low"
        case .moderate:
            return "Moderate"
        case .high:
            return "High"
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
            return "A mostly sedentary day with little walking and no regular workouts."
            
        case .moderate:
            return "A balanced routine with regular walking or light workouts during the week."
            
        case .high:
            return "An active routine with frequent workouts, intense training, or a physically demanding day."
        }
    }
}
