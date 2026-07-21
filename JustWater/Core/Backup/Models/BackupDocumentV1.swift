//
//  BackupDocumentV1.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

struct BackupDocumentV1: Codable, Equatable {

    static let appBundleIdentifier = "com.alexandrkazdev.JustWater"
    static let format = "\(appBundleIdentifier.lowercased()).backup"
    static let schemaVersion = 1

    let format: String
    let schemaVersion: Int
    let appVersion: String
    let buildNumber: String
    let createdAt: Date
    let entries: [BackupWaterEntryV1]
    let goalHistory: [BackupWaterGoalV1]
    let streakDays: [BackupStreakDayV1]
    let settings: BackupSettingsV1

    private enum CodingKeys: String, CodingKey {
        case format
        case schemaVersion
        case appVersion
        case buildNumber
        case createdAt
        case entries
        case goalHistory
        case streakDays
        case settings
    }

    init(
        format: String = BackupDocumentV1.format,
        schemaVersion: Int = BackupDocumentV1.schemaVersion,
        appVersion: String,
        buildNumber: String,
        createdAt: Date,
        entries: [BackupWaterEntryV1],
        goalHistory: [BackupWaterGoalV1],
        streakDays: [BackupStreakDayV1],
        settings: BackupSettingsV1
    ) {
        self.format = format
        self.schemaVersion = schemaVersion
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.createdAt = createdAt
        self.entries = entries
        self.goalHistory = goalHistory
        self.streakDays = streakDays
        self.settings = settings
    }
}
