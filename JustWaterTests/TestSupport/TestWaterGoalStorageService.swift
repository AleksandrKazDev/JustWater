//
//  TestWaterGoalStorageService.swift
//  JustWaterTests
//
//  Created by сонный on 26.05.2026.
//

import Foundation
@testable import JustWater

@MainActor
final class TestWaterGoalStorageService: WaterGoalStorageServicing {
    
    // MARK: - Properties
    
    var fallbackGoal: Int
    var goalsByDate: [Date: Int]
    
    // MARK: - Initializer
    
    init(
        fallbackGoal: Int = 2000,
        goalsByDate: [Date: Int] = [:]
    ) {
        self.fallbackGoal = fallbackGoal
        self.goalsByDate = goalsByDate
    }
    
    // MARK: - Public Methods
    
    func currentGoal() throws -> Int {
        fallbackGoal
    }
    
    func goal(
        for date: Date
    ) throws -> Int {
        let startOfDay = Calendar.current.startOfDay(
            for: date
        )
        
        return goalsByDate[startOfDay] ?? fallbackGoal
    }
    
    func goalsByDay(
        from startDate: Date,
        to endDate: Date
    ) throws -> [Date: Int] {
        var result: [Date: Int] = [:]
        
        var currentDate = Calendar.current.startOfDay(
            for: startDate
        )
        
        let endDay = Calendar.current.startOfDay(
            for: endDate
        )
        
        while currentDate < endDay {
            result[currentDate] = try goal(
                for: currentDate
            )
            
            guard let nextDate = Calendar.current.date(
                byAdding: .day,
                value: 1,
                to: currentDate
            ) else {
                break
            }
            
            currentDate = nextDate
        }
        
        return result
    }
    
    func updateGoal(
        _ goal: Int,
        effectiveDate: Date
    ) throws {
        let startOfDay = Calendar.current.startOfDay(
            for: effectiveDate
        )
        
        goalsByDate[startOfDay] = goal
        fallbackGoal = goal
    }
}
