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
            return "Day"
        case .week:
            return "Week"
        case .month:
            return "Month"
        case .year:
            return "Year"
        }
    }
}
