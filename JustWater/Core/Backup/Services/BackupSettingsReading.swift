//
//  BackupSettingsReading.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

protocol BackupSettingsReading {
    func settingsForBackup() -> BackupSettingsV1
}

struct AppSettingsBackupReader: BackupSettingsReading {

    func settingsForBackup() -> BackupSettingsV1 {
        BackupSettingsV1(
            dailyGoal: AppSettingsStorage.dailyGoal,
            isHapticsEnabled: AppSettingsStorage.isHapticsEnabled,
            appearanceModeRawValue: AppSettingsStorage.appearanceMode.rawValue,
            measurementUnitRawValue: AppSettingsStorage.measurementUnit.rawValue,
            areRemindersEnabled: AppSettingsStorage.areRemindersEnabled,
            reminderStartHour: AppSettingsStorage.reminderStartHour,
            reminderEndHour: AppSettingsStorage.reminderEndHour,
            reminderFrequencyRawValue: AppSettingsStorage.reminderFrequency.rawValue,
            isHealthSyncEnabled: AppSettingsStorage.isHealthSyncEnabled
        )
    }
}
