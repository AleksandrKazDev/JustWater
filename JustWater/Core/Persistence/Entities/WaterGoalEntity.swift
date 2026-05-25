//
//  WaterGoalEntity.swift
//  JustWater
//
//  Created by сонный on 25.05.2026.
//

import Foundation
import SwiftData

@Model
final class WaterGoalEntity {
    
    // MARK: - Properties
    
    @Attribute(.unique) var id: UUID
    var dailyGoal: Int
    var effectiveDate: Date
    
    // MARK: - Initializer
    
    init(
        id: UUID = UUID(),
        dailyGoal: Int,
        effectiveDate: Date
    ) {
        self.id = id
        self.dailyGoal = dailyGoal
        self.effectiveDate = effectiveDate
    }
}
