//
//  BackupExportResult.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

struct BackupExportResult: Equatable {
    let data: Data
    let suggestedFileName: String
    let createdAt: Date
    let entriesCount: Int
    let goalRecordsCount: Int
    let streakDaysCount: Int
}
