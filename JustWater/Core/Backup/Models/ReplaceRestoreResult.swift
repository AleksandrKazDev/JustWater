//
//  ReplaceRestoreResult.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation

struct ReplaceRestoreResult: Equatable, Sendable {
    let restoredEntriesCount: Int
    let restoredGoalsCount: Int
    let restoredStreakDaysCount: Int
    let currentDailyGoal: Int
}
