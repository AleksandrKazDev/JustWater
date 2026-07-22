//
//  MergeRestoreResult.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation

struct MergeRestoreCounts: Equatable, Sendable {
    let inserted: Int
    let unchanged: Int
    let conflicts: Int

    var skipped: Int {
        unchanged + conflicts
    }
}

struct MergeRestoreResult: Equatable, Sendable {
    let waterEntries: MergeRestoreCounts
    let goalHistory: MergeRestoreCounts
    let streakDays: MergeRestoreCounts
    let resolvedDailyGoal: Int

    var hasInsertedData: Bool {
        waterEntries.inserted > 0
        || goalHistory.inserted > 0
        || streakDays.inserted > 0
    }
}
