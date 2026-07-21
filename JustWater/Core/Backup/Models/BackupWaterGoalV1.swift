//
//  BackupWaterGoalV1.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

struct BackupWaterGoalV1: Codable, Equatable {
    let id: UUID
    let dailyGoal: Int
    let effectiveDate: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case dailyGoal
        case effectiveDate
    }
}
