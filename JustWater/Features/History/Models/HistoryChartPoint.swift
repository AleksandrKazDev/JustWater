//
//  HistoryChartPoint.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import Foundation

struct HistoryChartPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let label: String
    let amount: Int
    
    static func == (
        lhs: HistoryChartPoint,
        rhs: HistoryChartPoint
    ) -> Bool {
        lhs.date == rhs.date &&
        lhs.label == rhs.label &&
        lhs.amount == rhs.amount
    }
}
