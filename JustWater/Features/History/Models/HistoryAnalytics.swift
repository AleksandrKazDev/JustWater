//
//  HistoryAnalytics.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import Foundation

struct HistoryAnalytics: Equatable {
    let period: HistoryPeriod
    let statistics: HistoryStatistics
    let chartPoints: [HistoryChartPoint]
    let entries: [WaterEntry]
}

