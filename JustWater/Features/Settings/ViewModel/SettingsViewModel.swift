//
//  SettingsViewModel.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import SwiftUI
import UserNotifications

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Properties
    
    var dailyGoal: Int
    var isHapticsEnabled: Bool
    var appearanceMode: AppAppearanceMode
    var measurementUnit: MeasurementUnit
    
    var areRemindersEnabled: Bool
    var reminderStartHour: Int
    var reminderEndHour: Int
    var reminderFrequency: ReminderFrequency
    var notificationAuthorizationStatus: UNAuthorizationStatus
    
    // MARK: - Computed Properties
    
    var isNotificationPermissionDenied: Bool {
        notificationAuthorizationStatus == .denied
    }
    
    var reminderScheduleTitle: String {
        "\(formattedHour(reminderStartHour)) – \(formattedHour(reminderEndHour))"
    }
    
    // MARK: - Initializer
    
    init() {
        self.dailyGoal = AppSettingsStorage.dailyGoal
        self.isHapticsEnabled = AppSettingsStorage.isHapticsEnabled
        self.appearanceMode = AppSettingsStorage.appearanceMode
        self.measurementUnit = AppSettingsStorage.measurementUnit
        
        self.areRemindersEnabled = AppSettingsStorage.areRemindersEnabled
        self.reminderStartHour = AppSettingsStorage.reminderStartHour
        self.reminderEndHour = AppSettingsStorage.reminderEndHour
        self.reminderFrequency = AppSettingsStorage.reminderFrequency
        self.notificationAuthorizationStatus = .notDetermined
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
    
    func updateReminderStartHour(
        _ hour: Int
    ) {
        reminderStartHour = hour
        AppSettingsStorage.reminderStartHour = hour
        
        Task {
            await rescheduleRemindersIfNeeded()
        }
    }
    
    func updateReminderEndHour(
        _ hour: Int
    ) {
        reminderEndHour = hour
        AppSettingsStorage.reminderEndHour = hour
        
        Task {
            await rescheduleRemindersIfNeeded()
        }
    }
    
    func updateReminderFrequency(
        _ frequency: ReminderFrequency
    ) {
        reminderFrequency = frequency
        AppSettingsStorage.reminderFrequency = frequency
        
        Task {
            await rescheduleRemindersIfNeeded()
        }
    }
    
    func setRemindersEnabled(
        _ isEnabled: Bool
    ) {
        Task {
            await updateRemindersEnabled(isEnabled)
        }
    }
    
    func refreshNotificationAuthorizationStatus() {
        Task {
            notificationAuthorizationStatus = await NotificationService.getAuthorizationStatus()
            
            if notificationAuthorizationStatus == .denied {
                areRemindersEnabled = false
                AppSettingsStorage.areRemindersEnabled = false
                NotificationService.cancelHydrationReminders()
            }
        }
    }
    
    func openNotificationSettings() {
        NotificationService.openAppNotificationSettings()
    }
    
    func reload() {
        dailyGoal = AppSettingsStorage.dailyGoal
        isHapticsEnabled = AppSettingsStorage.isHapticsEnabled
        appearanceMode = AppSettingsStorage.appearanceMode
        measurementUnit = AppSettingsStorage.measurementUnit
        
        areRemindersEnabled = AppSettingsStorage.areRemindersEnabled
        reminderStartHour = AppSettingsStorage.reminderStartHour
        reminderEndHour = AppSettingsStorage.reminderEndHour
        reminderFrequency = AppSettingsStorage.reminderFrequency
        
        refreshNotificationAuthorizationStatus()
    }
    
    // MARK: - Private Methods
    
    private func updateRemindersEnabled(
        _ isEnabled: Bool
    ) async {
        if isEnabled {
            let status = await NotificationService.getAuthorizationStatus()
            notificationAuthorizationStatus = status
            
            let isAuthorized: Bool
            
            switch status {
            case .authorized, .provisional, .ephemeral:
                isAuthorized = true
                
            case .notDetermined:
                isAuthorized = await NotificationService.requestAuthorization()
                notificationAuthorizationStatus = await NotificationService.getAuthorizationStatus()
                
            case .denied:
                isAuthorized = false
                
            @unknown default:
                isAuthorized = false
            }
            
            guard isAuthorized else {
                areRemindersEnabled = false
                AppSettingsStorage.areRemindersEnabled = false
                NotificationService.cancelHydrationReminders()
                return
            }
            
            areRemindersEnabled = true
            AppSettingsStorage.areRemindersEnabled = true
            
            await scheduleReminders()
        } else {
            areRemindersEnabled = false
            AppSettingsStorage.areRemindersEnabled = false
            NotificationService.cancelHydrationReminders()
        }
    }
    
    private func rescheduleRemindersIfNeeded() async {
        guard areRemindersEnabled else {
            return
        }
        
        await scheduleReminders()
    }
    
    private func scheduleReminders() async {
        await NotificationService.scheduleHydrationReminders(
            startHour: reminderStartHour,
            endHour: reminderEndHour,
            frequency: reminderFrequency
        )
    }
    
    private func formattedHour(
        _ hour: Int
    ) -> String {
        String(format: "%02d:00", hour)
    }
}
