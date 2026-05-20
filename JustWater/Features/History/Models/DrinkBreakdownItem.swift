//
//  DrinkBreakdownItem.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import Foundation

struct DrinkBreakdownItem: Identifiable, Equatable {
    
    let drinkType: DrinkType
    let amount: Int
    
    var id: String {
        drinkType.id
    }
}
