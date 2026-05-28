//
//  HistoryPeriod.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import Foundation

enum HistoryPeriod: String, CaseIterable, Identifiable {
    case day
    case week
    case month
    case year
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .day:
            return String(localized: "history.period.day")
        
        case .week:
            return String(localized: "history.period.week")
            
        case .month:
            return String(localized: "history.period.month")
            
        case .year:
            return String(localized: "history.period.year")
        }
    }
}
