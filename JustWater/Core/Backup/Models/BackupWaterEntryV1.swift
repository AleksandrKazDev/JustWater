//
//  BackupWaterEntryV1.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

// Versioned DTOs keep the JSON contract stable as SwiftData models evolve.
struct BackupWaterEntryV1: Codable, Equatable {
    let id: UUID
    let amount: Int
    let date: Date
    let drinkTypeRawValue: String

    private enum CodingKeys: String, CodingKey {
        case id
        case amount
        case date
        case drinkTypeRawValue
    }
}
