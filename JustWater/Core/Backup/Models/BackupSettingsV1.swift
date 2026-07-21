//
//  BackupSettingsV1.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

struct BackupSettingsV1: Codable, Equatable {
    // Restore uses goalHistory as source of truth; this is fallback for an empty history.
    let dailyGoal: Int
    let isHapticsEnabled: Bool
    let appearanceModeRawValue: String
    let measurementUnitRawValue: String
    let areRemindersEnabled: Bool
    let reminderStartHour: Int
    let reminderEndHour: Int
    let reminderFrequencyRawValue: Int
    let isHealthSyncEnabled: Bool

    private enum CodingKeys: String, CodingKey {
        case dailyGoal
        case isHapticsEnabled
        case appearanceModeRawValue
        case measurementUnitRawValue
        case areRemindersEnabled
        case reminderStartHour
        case reminderEndHour
        case reminderFrequencyRawValue
        case isHealthSyncEnabled
    }
}
