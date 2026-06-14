//
//  AppSettingsStorage.swift
//  JustWater
//
//  Created by сонный on 15.05.2026.
//

import Foundation

enum AppSettingsStorage {
    
    // MARK: - Storage
    
    private static var defaults = UserDefaults.standard
    
    // MARK: - Keys
    
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let dailyGoal = "dailyGoal"
        static let isHapticsEnabled = "isHapticsEnabled"
        static let appearanceMode = "appearanceMode"
        static let measurementUnit = "measurementUnit"
        static let areRemindersEnabled = "areRemindersEnabled"
        static let reminderStartHour = "reminderStartHour"
        static let reminderEndHour = "reminderEndHour"
        static let reminderFrequency = "reminderFrequency"
        static let isHealthSyncEnabled = "isHealthSyncEnabled"
    }
    
    #if DEBUG
    static func useDefaults(
        _ defaults: UserDefaults
    ) {
        self.defaults = defaults
    }
    
    static func useStandardDefaults() {
        defaults = .standard
    }
    #endif
    
    
    // MARK: - Onboarding
    
    static var hasCompletedOnboarding: Bool {
        get {
            defaults.bool(
                forKey: Keys.hasCompletedOnboarding
            )
        }
        set {
            defaults.set(
                newValue,
                forKey: Keys.hasCompletedOnboarding
            )
        }
    }
    
    // MARK: - Daily Goal
    
    static var dailyGoal: Int {
        get {
            let value = defaults.integer(
                forKey: Keys.dailyGoal
            )
            
            return value == 0 ? 2500 : value
        }
        set {
            defaults.set(
                newValue,
                forKey: Keys.dailyGoal
            )
        }
    }
    
    // MARK: - Haptics
    
    static var isHapticsEnabled: Bool {
        get {
            if defaults.object(
                forKey: Keys.isHapticsEnabled
            ) == nil {
                return true
            }
            
            return defaults.bool(
                forKey: Keys.isHapticsEnabled
            )
        }
        set {
            defaults.set(
                newValue,
                forKey: Keys.isHapticsEnabled
            )
        }
    }
    
    // MARK: - Appearance
    
    static var appearanceMode: AppAppearanceMode {
        get {
            guard let rawValue = defaults.string(
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
            defaults.set(
                newValue.rawValue,
                forKey: Keys.appearanceMode
            )
        }
    }
    
    // MARK: - Units
    
    static var measurementUnit: MeasurementUnit {
        get {
            guard let rawValue = defaults.string(
                forKey: Keys.measurementUnit
            ) else {
                let defaultUnit = MeasurementUnit.defaultUnit()
                
                defaults.set(
                    defaultUnit.rawValue,
                    forKey: Keys.measurementUnit
                )
                
                return defaultUnit
            }
            
            guard let unit = MeasurementUnit(rawValue: rawValue) else {
                let fallbackUnit = MeasurementUnit.defaultUnit()
                
                defaults.set(
                    fallbackUnit.rawValue,
                    forKey: Keys.measurementUnit
                )
                
                return fallbackUnit
            }
            
            return unit
        }
        set {
            defaults.set(
                newValue.rawValue,
                forKey: Keys.measurementUnit
            )
        }
    }
    
    // MARK: - Reminders
    
    static var areRemindersEnabled: Bool {
        get {
            defaults.bool(
                forKey: Keys.areRemindersEnabled
            )
        }
        set {
            defaults.set(
                newValue,
                forKey: Keys.areRemindersEnabled
            )
        }
    }
    
    static var reminderStartHour: Int {
        get {
            guard defaults.object(
                forKey: Keys.reminderStartHour
            ) != nil else {
                return 9
            }
            
            return defaults.integer(
                forKey: Keys.reminderStartHour
            )
        }
        set {
            defaults.set(
                newValue,
                forKey: Keys.reminderStartHour
            )
        }
    }
    
    static var reminderEndHour: Int {
        get {
            guard defaults.object(
                forKey: Keys.reminderEndHour
            ) != nil else {
                return 22
            }
            
            return defaults.integer(
                forKey: Keys.reminderEndHour
            )
        }
        set {
            defaults.set(
                newValue,
                forKey: Keys.reminderEndHour
            )
        }
    }
    
    static var reminderFrequency: ReminderFrequency {
        get {
            let rawValue = defaults.integer(
                forKey: Keys.reminderFrequency
            )
            
            return ReminderFrequency(rawValue: rawValue) ?? .twoHours
        }
        set {
            defaults.set(
                newValue.rawValue,
                forKey: Keys.reminderFrequency
            )
        }
    }

    // MARK: - Health
    
    static var isHealthSyncEnabled: Bool {
        get {
            defaults.bool(
                forKey: Keys.isHealthSyncEnabled
            )
        }
        set {
            defaults.set(
                newValue,
                forKey: Keys.isHealthSyncEnabled
            )
        }
    }
}
