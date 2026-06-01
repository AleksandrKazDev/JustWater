//
//  HydrationStreakDayEntity.swift
//  JustWater
//
//  Created by сонный on 01.06.2026.
//

import Foundation
import SwiftData

@Model
final class HydrationStreakDayEntity {
    @Attribute(.unique) var dayStartDate: Date
    var createdAt: Date
    init(
        dayStartDate: Date,
        createdAt: Date
    ) {
        self.dayStartDate = dayStartDate
        self.createdAt = createdAt
    }
}
