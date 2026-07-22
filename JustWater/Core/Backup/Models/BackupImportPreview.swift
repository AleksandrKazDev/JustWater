//
//  BackupImportPreview.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation

struct BackupImportPreview: Equatable, Sendable {
    let fileName: String
    let createdAt: Date
    let appVersion: String
    let buildNumber: String
    let waterEntryCount: Int
    let goalHistoryCount: Int
    let streakDayCount: Int
    let fileSize: Int
}
