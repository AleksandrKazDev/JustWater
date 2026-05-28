//
//  AppAppearanceMode.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import SwiftUI

enum AppAppearanceMode: String, CaseIterable, Identifiable {
    
    case system
    case light
    case dark
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .system:
            return String(localized: "appearance.system")
            
        case .light:
            return String(localized: "appearance.light")
            
        case .dark:
            return String(localized: "appearance.dark")
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
            
        case .light:
            return .light
            
        case .dark:
            return .dark
        }
    }
}
