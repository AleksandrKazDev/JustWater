//
//  HistoryStatistics.swift.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import Foundation

struct HistoryStatistics: Equatable {
    let totalAmount: Int
    let averageAmount: Int
    let completionRate: Double
    let entriesCount: Int
    let goalReachedCount: Int
    let bestAmount: Int
    let bestLabel: String?
    
    static let empty = HistoryStatistics(
        totalAmount: 0,
        averageAmount: 0,
        completionRate: 0,
        entriesCount: 0,
        goalReachedCount: 0,
        bestAmount: 0,
        bestLabel: nil
    )
}
