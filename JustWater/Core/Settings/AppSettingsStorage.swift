//
//  AppSettingsStorage.swift
//  JustWater
//
//  Created by сонный on 15.05.2026.
//

import Foundation

enum AppSettingsStorage {
    
    // MARK: - Keys
    
    private enum Keys {
        static let dailyGoal = "dailyGoal"
        static let isHapticsEnabled = "isHapticsEnabled"
        static let appearanceMode = "appearanceMode"
        static let measurementUnit = "measurementUnit"
    }
    
    // MARK: - Daily Goal
    
    static var dailyGoal: Int {
        get {
            let value = UserDefaults.standard.integer(
                forKey: Keys.dailyGoal
            )
            
            return value == 0 ? 2500 : value
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: Keys.dailyGoal
            )
        }
    }
    
    // MARK: - Haptics
    
    static var isHapticsEnabled: Bool {
        get {
            if UserDefaults.standard.object(
                forKey: Keys.isHapticsEnabled
            ) == nil {
                return true
            }
            
            return UserDefaults.standard.bool(
                forKey: Keys.isHapticsEnabled
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: Keys.isHapticsEnabled
            )
        }
    }
    
    // MARK: - Appearance
    
    static var appearanceMode: AppAppearanceMode {
        get {
            guard let rawValue = UserDefaults.standard.string(
                forKey: Keys.appearanceMode
            ),
                  let mode = AppAppearanceMode(
                    rawValue: rawValue
                  ) else {
                return .system
            }
            
            return mode
        }
        set {
            UserDefaults.standard.set(
                newValue.rawValue,
                forKey: Keys.appearanceMode
            )
        }
    }
    
    // MARK: - Units
    
    static var measurementUnit: MeasurementUnit {
        get {
            guard let rawValue = UserDefaults.standard.string(
                forKey: Keys.measurementUnit
            ),
                  let unit = MeasurementUnit(
                    rawValue: rawValue
                  ) else {
                return .milliliters
            }
            
            return unit
        }
        set {
            UserDefaults.standard.set(
                newValue.rawValue,
                forKey: Keys.measurementUnit
            )
        }
    }
}
