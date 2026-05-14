//
//  WaterEntryEntity.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation
import SwiftData

@Model
final class WaterEntryEntity {
    
    var id: UUID
    var amount: Int
    var date: Date
    
    init(
        id: UUID = UUID(),
        amount: Int,
        date: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.date = date
    }
}
