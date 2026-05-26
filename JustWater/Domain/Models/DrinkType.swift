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
            return "Water"
        case .tea:
            return "Tea"
        case .coffee:
            return "Coffee"
        case .juice:
            return "Juice"
        case .soda:
            return "Soda"
        case .milk:
            return "Milk"
        case .other:
            return "Other"
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
            return .white.opacity(0.85)
        case .other:
            return AppColors.secondaryText
        }
    }
}
