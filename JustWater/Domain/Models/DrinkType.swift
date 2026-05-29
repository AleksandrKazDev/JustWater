//
//  DrinkType.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

enum DrinkType: String, CaseIterable, Codable, Identifiable {
    case water
    case tea
    case coffee
    case juice
    case soda
    case milk
    case other
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .water:
            return String(localized: "drink.water")
            
        case .tea:
            return String(localized: "drink.tea")
            
        case .coffee:
            return String(localized: "drink.coffee")
            
        case .juice:
            return String(localized: "drink.juice")
            
        case .soda:
            return String(localized: "drink.soda")
            
        case .milk:
            return String(localized: "drink.milk")
            
        case .other:
            return String(localized: "drink.other")
        }
    }
    
    var systemImage: String {
        switch self {
        case .water:
            return "drop.fill"
            
        case .tea:
            return "cup.and.saucer.fill"
            
        case .coffee:
            return "mug.fill"
            
        case .juice:
            return "takeoutbag.and.cup.and.straw.fill"
            
        case .soda:
            return "bubbles.and.sparkles"
            
        case .milk:
            return "mug.fill"
            
        case .other:
            return "ellipsis.circle.fill"
        }
    }
    
    var tintColor: Color {
        switch self {
        case .water:
            return AppColors.primaryBlue
            
        case .tea:
            return .orange.opacity(0.65)
            
        case .coffee:
            return .brown.opacity(0.75)
            
        case .juice:
            return .orange
            
        case .soda:
            return .cyan.opacity(0.75)
            
        case .milk:
            return Color(red: 0.56, green: 0.68, blue: 0.82)
            
        case .other:
            return AppColors.secondaryText
        }
    }
}
