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
            return String(localized: "reminder.frequency.one_hour")
            
        case .twoHours:
            return String(localized: "reminder.frequency.two_hours")
            
        case .threeHours:
            return String(localized: "reminder.frequency.three_hours")
            
        case .fourHours:
            return String(localized: "reminder.frequency.four_hours")
        }
    }
}
