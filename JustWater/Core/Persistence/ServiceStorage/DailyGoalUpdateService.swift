//
//  DailyGoalUpdateService.swift
//  JustWater
//
//  Created by сонный on 26.05.2026.
//

import Foundation

@MainActor
protocol DailyGoalUpdating {
    func updateDailyGoal(
        _ goal: Int
    ) throws
}

@MainActor
final class DailyGoalUpdateService: DailyGoalUpdating {
    
    // MARK: - Dependencies
    
    private let goalStorageService: WaterGoalStorageServicing
    
    // MARK: - Initializer
    
    init(
        goalStorageService: WaterGoalStorageServicing
    ) {
        self.goalStorageService = goalStorageService
    }
    
    // MARK: - Public Methods
    
    func updateDailyGoal(
        _ goal: Int
    ) throws {
        try goalStorageService.updateGoal(
            goal,
            effectiveDate: Date.now
        )
        
        AppSettingsStorage.dailyGoal = goal
    }
}
