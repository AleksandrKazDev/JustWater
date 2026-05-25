//
//  WaterEntrySnapshot.swift
//  JustWater
//
//  Created by сонный on 25.05.2026.
//

import Foundation

struct WaterEntrySnapshot: Equatable {
    let id: UUID
    let amount: Int
    let date: Date
    let drinkType: DrinkType
    
    init(entry: WaterEntry) {
        self.id = entry.id
        self.amount = entry.amount
        self.date = entry.date
        self.drinkType = entry.drinkType
    }
    
    var entry: WaterEntry {
        WaterEntry(
            id: id,
            amount: amount,
            date: date,
            drinkType: drinkType
        )
    }
}
