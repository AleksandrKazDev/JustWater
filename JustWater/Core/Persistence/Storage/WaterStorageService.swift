//
//  WaterStorageService.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation
import SwiftData

@MainActor
final class WaterStorageService {
    
    // MARK: - Properties
    
    private let context: ModelContext
    
    // MARK: - Initializer
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Public Methods
    
    func fetchEntries() throws -> [WaterEntry] {
        let descriptor = FetchDescriptor<WaterEntryEntity>(
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )
        
        let entities = try context.fetch(descriptor)
        
        return entities.map {
            WaterEntry(
                id: $0.id,
                amount: $0.amount,
                date: $0.date
            )
        }
    }
    
    func saveEntry(amount: Int) throws {
        let entity = WaterEntryEntity(amount: amount)
        
        context.insert(entity)
        
        try context.save()
    }
    
    func deleteEntry(id: UUID) throws {
        let descriptor = FetchDescriptor<WaterEntryEntity>()
        
        let entities = try context.fetch(descriptor)
        
        guard let entity = entities.first(where: { $0.id == id }) else {
            return
        }
        
        context.delete(entity)
        
        try context.save()
    }
    
    /// Home screen отображает только записи текущего календарного дня.
    /// Исторические записи сохраняются для будущей аналитики.
    func fetchEntries(for date: Date) throws -> [WaterEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        guard let endOfDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay
        ) else {
            return []
        }
        
        let descriptor = FetchDescriptor<WaterEntryEntity>(
            predicate: #Predicate { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            },
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )
        
        let entities = try context.fetch(descriptor)
        
        return entities.map {
            WaterEntry(
                id: $0.id,
                amount: $0.amount,
                date: $0.date
            )
        }
    }
    
    func fetchDailySummaries() throws -> [DailyHydrationSummary] {
        let descriptor = FetchDescriptor<WaterEntryEntity>(
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )
        
        let entities = try context.fetch(descriptor)
        let calendar = Calendar.current
        
        let groupedByDay = Dictionary(grouping: entities) { entity in
            calendar.startOfDay(for: entity.date)
        }
        
        return groupedByDay
            .map { date, entries in
                DailyHydrationSummary(
                    date: date,
                    totalAmount: entries.reduce(0) { $0 + $1.amount },
                    entriesCount: entries.count
                )
            }
            .sorted { $0.date > $1.date }
    }
    
    func fetchEntries(
        from startDate: Date,
        to endDate: Date
    ) throws -> [WaterEntry] {
        let descriptor = FetchDescriptor<WaterEntryEntity>(
            predicate: #Predicate { entry in
                entry.date >= startDate && entry.date < endDate
            },
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )
        
        let entities = try context.fetch(descriptor)
        
        return entities.map {
            WaterEntry(
                id: $0.id,
                amount: $0.amount,
                date: $0.date
            )
        }
    }
    
    func fetchEntries(
        for period: HistoryPeriod,
        referenceDate: Date = Date.now
    ) throws -> [WaterEntry] {
        let calendar = Calendar.current
        
        let startDate: Date
        let endDate: Date
        
        switch period {
        case .day:
            startDate = calendar.startOfDay(for: referenceDate)
            endDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: startDate
            ) ?? referenceDate
            
        case .week:
            let interval = calendar.dateInterval(
                of: .weekOfYear,
                for: referenceDate
            )
            
            startDate = interval?.start ?? calendar.startOfDay(for: referenceDate)
            endDate = interval?.end ?? referenceDate
            
        case .month:
            let interval = calendar.dateInterval(
                of: .month,
                for: referenceDate
            )
            
            startDate = interval?.start ?? calendar.startOfDay(for: referenceDate)
            endDate = interval?.end ?? referenceDate
            
        case .year:
            let interval = calendar.dateInterval(
                of: .year,
                for: referenceDate
            )
            
            startDate = interval?.start ?? calendar.startOfDay(for: referenceDate)
            endDate = interval?.end ?? referenceDate
        }
        
        return try fetchEntries(
            from: startDate,
            to: endDate
        )
    }
}
