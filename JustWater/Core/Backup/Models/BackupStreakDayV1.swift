//
//  BackupStreakDayV1.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

// Streak days are persisted derived state, so v1 exports them for an exact restore.
struct BackupStreakDayV1: Codable, Equatable {
    let dayStartDate: Date
    let createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case dayStartDate
        case createdAt
    }
}
