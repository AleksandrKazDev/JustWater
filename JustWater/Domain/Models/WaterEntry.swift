//
//  WaterEntry.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation

struct WaterEntry: Identifiable, Equatable {
    let id: UUID
    let amount: Int
    let date: Date
    let drinkType: DrinkType
    
    init(
        id: UUID = UUID(),
        amount: Int,
        date: Date = Date(),
        drinkType: DrinkType = .water
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.drinkType = drinkType
    }
}
