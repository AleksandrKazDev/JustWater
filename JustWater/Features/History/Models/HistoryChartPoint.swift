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
}
