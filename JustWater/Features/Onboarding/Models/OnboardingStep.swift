//
//  OnboardingStep.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import Foundation

enum OnboardingStep {
    case welcome
    case benefits
    case calculator
    case result
    
    var index: Int {
        switch self {
        case .welcome:
            return 0
            
        case .benefits:
            return 1
            
        case .calculator:
            return 2
            
        case .result:
            return 3
        }
    }
    
    static var totalCount: Int {
        4
    }
}
