//
//  TestWaterStorageService.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import Foundation
@testable import JustWater

enum TestStorageError: Error {
    case requestedFailure
}

@MainActor
final class TestWaterStorageService: WaterStorageServicing {
    
    // MARK: - Properties
    
    var entries: [WaterEntry]
    
    var fetchEntriesError: Error?
    var saveEntryError: Error?
    var updateEntryError: Error?
    var deleteEntryError: Error?
    var restoreEntryError: Error?
    
    // MARK: - Initializer
    
    init(
        entries: [WaterEntry] = []
    ) {
        self.entries = entries
    }
    
    // MARK: - Fetching
    
    func fetchEntries() throws -> [WaterEntry] {
        if let fetchEntriesError {
            throw fetchEntriesError
        }
        
        return sortedEntries
    }
    
    func fetchEntries(
        for date: Date
    ) throws -> [WaterEntry] {
        if let fetchEntriesError {
            throw fetchEntriesError
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        guard let endOfDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay
        ) else {
            return []
        }
        
        return entries
            .filter { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            }
            .sorted { lhs, rhs in
                lhs.date > rhs.date
            }
    }
    
    func fetchEntries(
        from startDate: Date,
        to endDate: Date
    ) throws -> [WaterEntry] {
        if let fetchEntriesError {
            throw fetchEntriesError
        }
        
        return entries
            .filter { entry in
                entry.date >= startDate && entry.date < endDate
            }
            .sorted { lhs, rhs in
                lhs.date > rhs.date
            }
    }
    
    func fetchEntries(
        for period: HistoryPeriod,
        referenceDate: Date
    ) throws -> [WaterEntry] {
        if let fetchEntriesError {
            throw fetchEntriesError
        }
        
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
    func saveEntry(
        amount: Int
    ) throws -> WaterEntry {
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
        drinkType: DrinkType
    ) throws -> WaterEntry {
        if let saveEntryError {
            throw saveEntryError
        }
        
        let entry = WaterEntry(
            id: UUID(),
            amount: amount,
            date: date,
            drinkType: drinkType
        )
        
        entries.append(entry)
        
        return entry
    }
    
    // MARK: - Updating
    
    func updateEntry(
        id: UUID,
        amount: Int,
        date: Date,
        drinkType: DrinkType
    ) throws {
        if let updateEntryError {
            throw updateEntryError
        }
        
        guard let index = entries.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        entries[index] = WaterEntry(
            id: id,
            amount: amount,
            date: date,
            drinkType: drinkType
        )
    }
    
    // MARK: - Deleting
    
    func deleteEntry(
        id: UUID
    ) throws {
        if let deleteEntryError {
            throw deleteEntryError
        }
        
        entries.removeAll { entry in
            entry.id == id
        }
    }
    
    // MARK: - Restoring
    
    @discardableResult
    func restoreEntry(
        from snapshot: WaterEntrySnapshot
    ) throws -> WaterEntry {
        if let restoreEntryError {
            throw restoreEntryError
        }
        
        let entry = snapshot.entry
        
        entries.append(entry)
        
        return entry
    }
    
    // MARK: - Private Properties
    
    private var sortedEntries: [WaterEntry] {
        entries.sorted { lhs, rhs in
            lhs.date > rhs.date
        }
    }
    
    // MARK: - Private Methods
    
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
}
