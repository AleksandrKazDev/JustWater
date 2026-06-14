//
//  HealthKitServiceError.swift
//  JustWater
//
//  Created by сонный on 14.06.2026.
//

import Foundation

enum HealthKitServiceError: LocalizedError {
    case healthDataUnavailable
    case waterTypeUnavailable
    case invalidWaterAmount
    
    var errorDescription: String? {
        switch self {
        case .healthDataUnavailable:
            return "Health data is not available on this device."
            
        case .waterTypeUnavailable:
            return "Water type is unavailable in HealthKit."
            
        case .invalidWaterAmount:
            return "Water amount must be greater than zero."
        }
    }
}
