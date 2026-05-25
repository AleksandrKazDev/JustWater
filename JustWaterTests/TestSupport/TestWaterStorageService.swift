//
//  TestWaterStorageService.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import Foundation
@testable import JustWater

@MainActor
final class TestWaterStorageService: WaterStorageServicing {
    
    // MARK: - Properties
    
    var entries: [WaterEntry]
    
    // MARK: - Initializer
    
    init(
        entries: [WaterEntry] = []
    ) {
        self.entries = entries
    }
    
    // MARK: - Fetching
    
    func fetchEntries() throws -> [WaterEntry] {
        sortedEntries
    }
    
    func fetchEntries(
        for date: Date
    ) throws -> [WaterEntry] {
        sortedEntries
    }
    
    func fetchEntries(
        from startDate: Date,
        to endDate: Date
    ) throws -> [WaterEntry] {
        entries
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
        sortedEntries
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
        entries.removeAll { entry in
            entry.id == id
        }
    }
    
    // MARK: - Restoring
    
    @discardableResult
    func restoreEntry(
        from snapshot: WaterEntrySnapshot
    ) throws -> WaterEntry {
        let entry = snapshot.entry
        
        entries.append(entry)
        
        return entry
    }
    
    // MARK: - Helpers
    
    private var sortedEntries: [WaterEntry] {
        entries.sorted { lhs, rhs in
            lhs.date > rhs.date
        }
    }
}
