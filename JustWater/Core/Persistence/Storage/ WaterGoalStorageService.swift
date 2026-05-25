//
//  File.swift
//  JustWater
//
//  Created by сонный on 25.05.2026.
//

import Foundation
import SwiftData

@MainActor
protocol WaterGoalStorageServicing {
    
    func currentGoal() throws -> Int
    
    func goal(
        for date: Date
    ) throws -> Int
    
    func goalsByDay(
        from startDate: Date,
        to endDate: Date
    ) throws -> [Date: Int]
    
    func updateGoal(
        _ goal: Int,
        effectiveDate: Date
    ) throws
}

@MainActor
final class WaterGoalStorageService: WaterGoalStorageServicing {
    
    // MARK: - Properties
    
    private let context: ModelContext
    private let calendar: Calendar
    
    // MARK: - Initializer
    
    init(
        context: ModelContext,
        calendar: Calendar = .current
    ) {
        self.context = context
        self.calendar = calendar
    }
    
    // MARK: - Public Methods
    
    func currentGoal() throws -> Int {
        try ensureInitialGoalIfNeeded()
        
        let descriptor = FetchDescriptor<WaterGoalEntity>(
            sortBy: [
                SortDescriptor(\.effectiveDate, order: .reverse)
            ]
        )
        
        return try context.fetch(descriptor).first?.dailyGoal
        ?? AppSettingsStorage.dailyGoal
    }
    
    func goal(
        for date: Date
    ) throws -> Int {
        try ensureInitialGoalIfNeeded()
        
        let startOfDay = calendar.startOfDay(for: date)
        
        let descriptor = FetchDescriptor<WaterGoalEntity>(
            predicate: #Predicate { entity in
                entity.effectiveDate <= startOfDay
            },
            sortBy: [
                SortDescriptor(\.effectiveDate, order: .reverse)
            ]
        )
        
        return try context.fetch(descriptor).first?.dailyGoal
        ?? AppSettingsStorage.dailyGoal
    }
    
    func goalsByDay(
        from startDate: Date,
        to endDate: Date
    ) throws -> [Date: Int] {
        try ensureInitialGoalIfNeeded()
        
        let startDay = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        
        var result: [Date: Int] = [:]
        var currentDate = startDay
        
        while currentDate < endDay {
            result[currentDate] = try goal(for: currentDate)
            
            guard let nextDate = calendar.date(
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
        let normalizedDate = calendar.startOfDay(
            for: effectiveDate
        )
        
        if let existingEntity = try fetchGoalEntity(
            effectiveDate: normalizedDate
        ) {
            existingEntity.dailyGoal = goal
        } else {
            let entity = WaterGoalEntity(
                dailyGoal: goal,
                effectiveDate: normalizedDate
            )
            
            context.insert(entity)
        }
        
        try context.save()
    }
    
    // MARK: - Private Methods
    
    private func ensureInitialGoalIfNeeded() throws {
        let descriptor = FetchDescriptor<WaterGoalEntity>()
        let recordsCount = try context.fetchCount(descriptor)
        
        guard recordsCount == 0 else { return }
        
        let entity = WaterGoalEntity(
            dailyGoal: AppSettingsStorage.dailyGoal,
            effectiveDate: .distantPast
        )
        
        context.insert(entity)
        
        try context.save()
    }
    
    private func fetchGoalEntity(
        effectiveDate: Date
    ) throws -> WaterGoalEntity? {
        let descriptor = FetchDescriptor<WaterGoalEntity>(
            predicate: #Predicate { entity in
                entity.effectiveDate == effectiveDate
            }
        )
        
        return try context.fetch(descriptor).first
    }
}
