//
//  ReminderFrequency.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import Foundation

enum ReminderFrequency: Int, CaseIterable, Identifiable {
    
    case oneHour = 1
    case twoHours = 2
    case threeHours = 3
    case fourHours = 4
    
    var id: Int {
        rawValue
    }
    
    var title: String {
        switch self {
        case .oneHour:
            return "Every hour"
        case .twoHours:
            return "Every 2 hours"
        case .threeHours:
            return "Every 3 hours"
        case .fourHours:
            return "Every 4 hours"
        }
    }
}
