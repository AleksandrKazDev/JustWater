//
//  DailyHydrationSummary.swift
//  JustWater
//
//  Created by сонный on 15.05.2026.
//

import Foundation

struct DailyHydrationSummary: Identifiable, Equatable {
    
    let date: Date
    let totalAmount: Int
    let entriesCount: Int

    var id: Date {
        date
    }

}
