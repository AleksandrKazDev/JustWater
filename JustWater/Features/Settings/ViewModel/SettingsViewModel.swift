//
//  SettingsViewModel.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import SwiftUI

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Properties
    
    var dailyGoal: Int
    var isHapticsEnabled: Bool
    var appearanceMode: AppAppearanceMode
    var measurementUnit: MeasurementUnit
    
    // MARK: - Initializer
    
    init() {
        self.dailyGoal = AppSettingsStorage.dailyGoal
        self.isHapticsEnabled = AppSettingsStorage.isHapticsEnabled
        self.appearanceMode = AppSettingsStorage.appearanceMode
        self.measurementUnit = AppSettingsStorage.measurementUnit
    }
    
    // MARK: - Public Methods
    
    func updateDailyGoal(
        _ goal: Int
    ) {
        AppSettingsStorage.dailyGoal = goal
        dailyGoal = goal
    }
    
    func updateHapticsEnabled(
        _ isEnabled: Bool
    ) {
        AppSettingsStorage.isHapticsEnabled = isEnabled
        isHapticsEnabled = isEnabled
    }
    
    func updateAppearanceMode(
        _ mode: AppAppearanceMode
    ) {
        AppSettingsStorage.appearanceMode = mode
        appearanceMode = mode
        
        NotificationCenter.default.post(
            name: .appAppearanceDidChange,
            object: nil
        )
    }
    
    func updateMeasurementUnit(
        _ unit: MeasurementUnit
    ) {
        AppSettingsStorage.measurementUnit = unit
        measurementUnit = unit
    }
    
    func reload() {
        dailyGoal = AppSettingsStorage.dailyGoal
        isHapticsEnabled = AppSettingsStorage.isHapticsEnabled
        appearanceMode = AppSettingsStorage.appearanceMode
        measurementUnit = AppSettingsStorage.measurementUnit
    }
}
