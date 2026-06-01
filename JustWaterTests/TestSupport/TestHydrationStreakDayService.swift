//
//  TestHydrationStreakDayService.swift
//  JustWaterTests
//
//  Created by сонный on 01.06.2026.
//

import Foundation
@testable import JustWater
@MainActor

final class TestHydrationStreakDayService: HydrationStreakDayTracking {
    
    var markedEntryDates: [Date] = []
    var streakDays: Set<Date> = []
    var markError: Error?
    var fetchError: Error?

    func markTodayIfEntryIsForToday(
        entryDate: Date
    ) throws {
        if let markError {
            throw markError
        }

        markedEntryDates.append(entryDate)
    }
    
    func fetchStreakDays() throws -> Set<Date> {
        if let fetchError {
            throw fetchError
        }
        return streakDays
    }
}
