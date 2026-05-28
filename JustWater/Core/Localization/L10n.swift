//
//  L10n.swift
//  JustWater
//
//  Created by сонный on 27.05.2026.
//

import Foundation

enum L10n {
    
    // MARK: - Common
    
    static let cancel = String(localized: "common.cancel")
    static let done = String(localized: "common.done")
    static let add = String(localized: "common.add")
    static let save = String(localized: "common.save")
    static let delete = String(localized: "common.delete")
    static let edit = String(localized: "common.edit")
    
    // MARK: - Tabs / Screens
    
    static let homeTitle = String(localized: "home.title")
    static let historyTitle = String(localized: "history.title")
    static let settingsTitle = String(localized: "settings.title")
    static let goalCalculatorTitle = String(localized: "goal_calculator.title")
    
    // MARK: - Settings
    
    static let settingsHeader = String(localized: "settings.header")
    static let settingsDailyGoal = String(localized: "settings.daily_goal")
    static let settingsChange = String(localized: "settings.change")
    static let settingsAppearance = String(localized: "settings.appearance")
    static let settingsPreferences = String(localized: "settings.preferences")
    static let settingsReminders = String(localized: "settings.reminders")
    static let settingsApp = String(localized: "settings.app")
    
    // MARK: - Onboarding
    
    static let onboardingGetStarted = String(localized: "onboarding.get_started")
    static let onboardingContinue = String(localized: "onboarding.continue")
    static let onboardingStartTracking = String(localized: "onboarding.start_tracking")
    
    // MARK: - History
    
    static let historySelectDate = String(localized: "history.select_date")
    static let historySelectWeek = String(localized: "history.select_week")
    static let historySelectMonth = String(localized: "history.select_month")
    static let historySelectYear = String(localized: "history.select_year")
    
    // MARK: - Undo
    
    static func waterAdded(_ drinkTitle: String) -> String {
        String(
            format: String(localized: "undo.added"),
            drinkTitle
        )
    }
    
    static func waterDeleted(_ drinkTitle: String) -> String {
        String(
            format: String(localized: "undo.deleted"),
            drinkTitle
        )
    }
}
