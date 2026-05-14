//
//  WaterEntry.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation

struct WaterEntry: Identifiable, Equatable {
    let id: UUID
    var amount: Int
    let date: Date
    
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
