//
//  BackupExportError.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

enum BackupExportError: Error, Equatable {
    case invalidEntryAmount(id: UUID, amount: Int)
    case invalidGoalAmount(id: UUID, dailyGoal: Int)
    case invalidSettingsDailyGoal(Int)
    case invalidReminderHour(Int)
    case invalidDate
    case readFailed
    case encodingFailed
}
