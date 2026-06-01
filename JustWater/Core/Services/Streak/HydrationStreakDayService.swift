//
//  HydrationStreakDayService.swift
//  JustWater
//
//  Created by сонный on 01.06.2026.
//

import Foundation
import SwiftData

@MainActor
protocol HydrationStreakDayTracking {
    func markTodayIfEntryIsForToday(
        entryDate: Date
    ) throws
    
    func fetchStreakDays() throws -> Set<Date>
}

@MainActor
final class HydrationStreakDayService: HydrationStreakDayTracking {
    
    // MARK: - Properties
    
    private let context: ModelContext
    private let calendar: Calendar
    private let dateProvider: DateProviding
    
    // MARK: - Initializer
    
    init(
        context: ModelContext,
        calendar: Calendar = .current,
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        self.context = context
        self.calendar = calendar
        self.dateProvider = dateProvider
    }
    
    // MARK: - Public Methods
    
    func markTodayIfEntryIsForToday(
        entryDate: Date
    ) throws {
        let now = dateProvider.now
        
        guard calendar.isDate(
            entryDate,
            inSameDayAs: now
        ) else {
            return
        }
        
        let today = calendar.startOfDay(
            for: now
        )
        
        let descriptor = FetchDescriptor<HydrationStreakDayEntity>(
            predicate: #Predicate { entity in
                entity.dayStartDate == today
            }
        )
        
        if try context.fetch(descriptor).first != nil {
            return
        }
        
        let entity = HydrationStreakDayEntity(
            dayStartDate: today,
            createdAt: now
        )
        
        context.insert(entity)
        
        try context.save()
    }
    
    func fetchStreakDays() throws -> Set<Date> {
        let descriptor = FetchDescriptor<HydrationStreakDayEntity>(
            sortBy: [
                SortDescriptor(\.dayStartDate, order: .reverse)
            ]
        )
        
        let entities = try context.fetch(descriptor)
        
        return Set(
            entities.map {
                calendar.startOfDay(
                    for: $0.dayStartDate
                )
            }
        )
    }
}
