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
            return "Male"
            
        case .female:
            return "Female"
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
