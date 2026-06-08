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
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let dailyGoal = "dailyGoal"
        static let isHapticsEnabled = "isHapticsEnabled"
        static let appearanceMode = "appearanceMode"
        static let measurementUnit = "measurementUnit"
        static let areRemindersEnabled = "areRemindersEnabled"
        static let reminderStartHour = "reminderStartHour"
        static let reminderEndHour = "reminderEndHour"
        static let reminderFrequency = "reminderFrequency"
    }
    
    
    // MARK: - Onboarding
    
    static var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(
                forKey: Keys.hasCompletedOnboarding
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: Keys.hasCompletedOnboarding
            )
        }
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
            ) else {
                let defaultUnit = MeasurementUnit.defaultUnit()
                
                UserDefaults.standard.set(
                    defaultUnit.rawValue,
                    forKey: Keys.measurementUnit
                )
                
                return defaultUnit
            }
            
            guard let unit = MeasurementUnit(rawValue: rawValue) else {
                let fallbackUnit = MeasurementUnit.defaultUnit()
                
                UserDefaults.standard.set(
                    fallbackUnit.rawValue,
                    forKey: Keys.measurementUnit
                )
                
                return fallbackUnit
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
    
    // MARK: - Reminders
    
    static var areRemindersEnabled: Bool {
        get {
            UserDefaults.standard.bool(
                forKey: Keys.areRemindersEnabled
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: Keys.areRemindersEnabled
            )
        }
    }
    
    static var reminderStartHour: Int {
        get {
            guard UserDefaults.standard.object(
                forKey: Keys.reminderStartHour
            ) != nil else {
                return 9
            }
            
            return UserDefaults.standard.integer(
                forKey: Keys.reminderStartHour
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: Keys.reminderStartHour
            )
        }
    }
    
    static var reminderEndHour: Int {
        get {
            guard UserDefaults.standard.object(
                forKey: Keys.reminderEndHour
            ) != nil else {
                return 22
            }
            
            return UserDefaults.standard.integer(
                forKey: Keys.reminderEndHour
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: Keys.reminderEndHour
            )
        }
    }
    
    static var reminderFrequency: ReminderFrequency {
        get {
            let rawValue = UserDefaults.standard.integer(
                forKey: Keys.reminderFrequency
            )
            
            return ReminderFrequency(rawValue: rawValue) ?? .twoHours
        }
        set {
            UserDefaults.standard.set(
                newValue.rawValue,
                forKey: Keys.reminderFrequency
            )
        }
    }
}
