//
//  AppSettingsStorage.swift
//  JustWater
//
//  Created by сонный on 15.05.2026.
//

import Foundation

enum AppSettingsStorage {
    
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let dailyGoal = "dailyGoal"
    }
    
    static var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasCompletedOnboarding)
        }
    }
    
    static var dailyGoal: Int {
        get {
            let value = UserDefaults.standard.integer(forKey: Keys.dailyGoal)
            return value == 0 ? 2000 : value
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.dailyGoal)
        }
    }
}
