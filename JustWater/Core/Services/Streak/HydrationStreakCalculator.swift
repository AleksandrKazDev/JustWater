//
//  HydrationStreakCalculator.swift
//  JustWater
//
//  Created by сонный on 01.06.2026.
//

import Foundation

protocol HydrationStreakCalculating {
    func currentStreak(
        streakDays: Set<Date>,
        currentDate: Date,
        calendar: Calendar
    ) -> Int
}

struct HydrationStreakCalculator: HydrationStreakCalculating {
    
    func currentStreak(
        streakDays: Set<Date>,
        currentDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let normalizedDays = Set(
            streakDays.map {
                calendar.startOfDay(
                    for: $0
                )
            }
        )
        
        let today = calendar.startOfDay(
            for: currentDate
        )
        
        if normalizedDays.contains(today) {
            return countStreak(
                endingAt: today,
                streakDays: normalizedDays,
                calendar: calendar
            )
        }
        
        guard let yesterday = calendar.date(
            byAdding: .day,
            value: -1,
            to: today
        ) else {
            return 0
        }
        
        return countStreak(
            endingAt: yesterday,
            streakDays: normalizedDays,
            calendar: calendar
        )
    }
    
    private func countStreak(
        endingAt date: Date,
        streakDays: Set<Date>,
        calendar: Calendar
    ) -> Int {
        var currentDay = calendar.startOfDay(
            for: date
        )
        
        var result = 0
        
        while streakDays.contains(currentDay) {
            result += 1
            
            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: currentDay
            ) else {
                return result
            }
            
            currentDay = previousDay
        }
        
        return result
    }
}
