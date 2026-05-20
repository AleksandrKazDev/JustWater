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
    var drinkTypeRawValue: String
    
    init(
        id: UUID = UUID(),
        amount: Int,
        date: Date = Date(),
        drinkTypeRawValue: String = DrinkType.water.rawValue
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.drinkTypeRawValue = drinkTypeRawValue
    }
}
