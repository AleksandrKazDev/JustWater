//
//  Gender.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import Foundation

enum Gender: String, CaseIterable, Identifiable {
    case male
    case female
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .male:
            return String(localized: "gender.male")
            
        case .female:
            return String(localized: "gender.female")
        }
    }
    
    var additionalWater: Int {
        switch self {
        case .male:
            return 150
            
        case .female:
            return 0
        }
    }
}
