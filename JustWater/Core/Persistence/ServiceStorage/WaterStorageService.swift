//
//  WaterStorageService.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation
import SwiftData

@MainActor
protocol WaterStorageServicing {
    func fetchEntries() throws -> [WaterEntry]
    
    func fetchEntries(
        for date: Date
    ) throws -> [WaterEntry]
    
    func fetchEntries(
        from startDate: Date,
        to endDate: Date
    ) throws -> [WaterEntry]
    
    func fetchEntries(
        for period: HistoryPeriod,
        referenceDate: Date
    ) throws -> [WaterEntry]
    
    @discardableResult
    func saveEntry(
        amount: Int
    ) throws -> WaterEntry
    
    @discardableResult
    func saveEntry(
        amount: Int,
        date: Date,
        drinkType: DrinkType
    ) throws -> WaterEntry
    
    func updateEntry(
        id: UUID,
        amount: Int,
        date: Date,
        drinkType: DrinkType
    ) throws
    
    func deleteEntry(
        id: UUID
    ) throws
    
    @discardableResult
    func restoreEntry(
        from snapshot: WaterEntrySnapshot
    ) throws -> WaterEntry
}

@MainActor
final class WaterStorageService: WaterStorageServicing {
    
    // MARK: - Properties
    
    private let context: ModelContext
    
    // MARK: - Initializer
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Fetching
    
    func fetchEntries() throws -> [WaterEntry] {
        let descriptor = FetchDescriptor<WaterEntryEntity>(
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )
        
        return try fetchDomainModels(using: descriptor)
    }
    
    /// Home screen отображает только записи выбранного календарного дня.
    /// Исторические записи сохраняются для аналитики.
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
        
        return try fetchEntries(
            from: startOfDay,
            to: endOfDay
        )
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
        
        return try fetchDomainModels(using: descriptor)
    }
    
    func fetchEntries(
        for period: HistoryPeriod,
        referenceDate: Date = Date.now
    ) throws -> [WaterEntry] {
        let interval = dateInterval(
            for: period,
            referenceDate: referenceDate
        )
        
        return try fetchEntries(
            from: interval.start,
            to: interval.end
        )
    }
    
    // MARK: - Saving
    
    @discardableResult
    func saveEntry(amount: Int) throws -> WaterEntry {
        try saveEntry(
            amount: amount,
            date: Date(),
            drinkType: .water
        )
    }
    
    @discardableResult
    func saveEntry(
        amount: Int,
        date: Date,
        drinkType: DrinkType = .water
    ) throws -> WaterEntry {
        let id = UUID()
        let normalizedDate = try uniqueDateIfNeeded(date)
        
        let entity = WaterEntryEntity(
            id: id,
            amount: amount,
            date: normalizedDate,
            drinkTypeRawValue: drinkType.rawValue
        )
        
        context.insert(entity)
        
        try context.save()
        
        return WaterEntry(
            id: id,
            amount: amount,
            date: normalizedDate,
            drinkType: drinkType
        )
    }
    
    // MARK: - Updating
    
    func updateEntry(
        id: UUID,
        amount: Int,
        date: Date,
        drinkType: DrinkType
    ) throws {
        guard let entity = try fetchEntity(id: id) else {
            return
        }
        
        let normalizedDate = try uniqueDateIfNeeded(
            date,
            excludingEntryID: id
        )
        
        entity.amount = amount
        entity.date = normalizedDate
        entity.drinkTypeRawValue = drinkType.rawValue
        
        try context.save()
    }
    
    // MARK: - Deleting
    
    func deleteEntry(id: UUID) throws {
        guard let entity = try fetchEntity(id: id) else {
            return
        }
        
        context.delete(entity)
        
        try context.save()
    }
    
    // MARK: - Restoring
    
    @discardableResult
    func restoreEntry(
        from snapshot: WaterEntrySnapshot
    ) throws -> WaterEntry {
        let entity = WaterEntryEntity(
            id: snapshot.id,
            amount: snapshot.amount,
            date: snapshot.date,
            drinkTypeRawValue: snapshot.drinkType.rawValue
        )
        
        context.insert(entity)
        
        try context.save()
        
        return snapshot.entry
    }
    
    // MARK: - Private Fetching
    
    private func fetchDomainModels(
        using descriptor: FetchDescriptor<WaterEntryEntity>
    ) throws -> [WaterEntry] {
        let entities = try context.fetch(descriptor)
        
        return entities.map(makeDomainModel)
    }
    
    private func fetchEntity(
        id: UUID
    ) throws -> WaterEntryEntity? {
        let descriptor = FetchDescriptor<WaterEntryEntity>(
            predicate: #Predicate { entry in
                entry.id == id
            }
        )
        
        return try context.fetch(descriptor).first
    }
    
    /// Сохраняет визуальную сортировку записей, когда несколько записей отображают одну и ту же минуту.
    /// Избегаею изменения схемы SwiftData, поскольку приложение уже опубликовано.
    // MARK: - Private Helpers
    
    private func uniqueDateIfNeeded(
        _ date: Date,
        excludingEntryID excludedID: UUID? = nil
    ) throws -> Date {
        let calendar = Calendar.current
        
        guard let minuteInterval = calendar.dateInterval(
            of: .minute,
            for: date
        ) else {
            return date
        }
        
        let descriptor = FetchDescriptor<WaterEntryEntity>(
            predicate: #Predicate { entry in
                entry.date >= minuteInterval.start && entry.date < minuteInterval.end
            },
            sortBy: [
                SortDescriptor(\.date, order: .reverse)
            ]
        )
        
        let entriesInSameMinute = try context.fetch(descriptor)
            .filter { entry in
                entry.id != excludedID
            }
        
        guard let latestEntry = entriesInSameMinute.first else {
            return date
        }
        
        let candidateDate = latestEntry.date.addingTimeInterval(0.001)
        
        if candidateDate < minuteInterval.end {
            return candidateDate
        }
        
        return date
    }
    
    private func dateInterval(
        for period: HistoryPeriod,
        referenceDate: Date
    ) -> DateInterval {
        let calendar = Calendar.current
        
        switch period {
        case .day:
            let startDate = calendar.startOfDay(for: referenceDate)
            let endDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: startDate
            ) ?? referenceDate
            
            return DateInterval(
                start: startDate,
                end: endDate
            )
            
        case .week:
            return calendar.dateInterval(
                of: .weekOfYear,
                for: referenceDate
            ) ?? fallbackDateInterval(
                referenceDate: referenceDate,
                calendar: calendar
            )
            
        case .month:
            return calendar.dateInterval(
                of: .month,
                for: referenceDate
            ) ?? fallbackDateInterval(
                referenceDate: referenceDate,
                calendar: calendar
            )
            
        case .year:
            return calendar.dateInterval(
                of: .year,
                for: referenceDate
            ) ?? fallbackDateInterval(
                referenceDate: referenceDate,
                calendar: calendar
            )
        }
    }
    
    private func fallbackDateInterval(
        referenceDate: Date,
        calendar: Calendar
    ) -> DateInterval {
        let startDate = calendar.startOfDay(for: referenceDate)
        let endDate = calendar.date(
            byAdding: .day,
            value: 1,
            to: startDate
        ) ?? referenceDate
        
        return DateInterval(
            start: startDate,
            end: endDate
        )
    }
    
    private func makeDomainModel(
        from entity: WaterEntryEntity
    ) -> WaterEntry {
        WaterEntry(
            id: entity.id,
            amount: entity.amount,
            date: entity.date,
            drinkType: DrinkType(rawValue: entity.drinkTypeRawValue) ?? .water
        )
    }
}
