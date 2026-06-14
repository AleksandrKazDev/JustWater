//
//  AppSettingsStorageTestSupport.swift
//  JustWaterTests
//
//  Created by Codex on 13.06.2026.
//

import Foundation
@testable import JustWater

enum AppSettingsStorageTestSupport {
    
    private static let keys = [
        "hasCompletedOnboarding",
        "dailyGoal",
        "isHapticsEnabled",
        "appearanceMode",
        "measurementUnit",
        "areRemindersEnabled",
        "reminderStartHour",
        "reminderEndHour",
        "reminderFrequency",
        "isHealthSyncEnabled"
    ]
    
    private static var storedValues: [String: Any] = [:]
    
    static func setUpIsolatedDefaults() {
        storedValues = [:]
        
        for key in keys {
            if let value = UserDefaults.standard.object(
                forKey: key
            ) {
                storedValues[key] = value
            }
            
            UserDefaults.standard.removeObject(
                forKey: key
            )
        }
    }
    
    static func tearDownIsolatedDefaults() {
        for key in keys {
            UserDefaults.standard.removeObject(
                forKey: key
            )
        }
        
        for (key, value) in storedValues {
            UserDefaults.standard.set(
                value,
                forKey: key
            )
        }
        
        storedValues = [:]
    }
}
