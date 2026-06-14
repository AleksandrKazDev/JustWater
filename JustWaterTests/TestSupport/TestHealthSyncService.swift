//
//  TestHealthSyncService.swift
//  JustWaterTests
//
//  Created by сонный on 14.06.2026.
//


import Foundation
@testable import JustWater

@MainActor
final class TestHealthSyncService: HealthSyncServicing {
    
    private(set) var syncedAddedWaterCount = 0
    private(set) var syncedDeletedWaterCount = 0
    private(set) var syncedUpdatedWaterCount = 0
    
    private(set) var lastAddedAmount: Int?
    private(set) var lastAddedDate: Date?
    private(set) var lastAddedEntryID: UUID?
    
    private(set) var lastDeletedEntryID: UUID?
    
    private(set) var lastUpdatedAmount: Int?
    private(set) var lastUpdatedDate: Date?
    private(set) var lastUpdatedEntryID: UUID?
    
    func syncAddedWater(
        amountInMilliliters: Int,
        date: Date,
        entryID: UUID
    ) async {
        syncedAddedWaterCount += 1
        lastAddedAmount = amountInMilliliters
        lastAddedDate = date
        lastAddedEntryID = entryID
    }
    
    func syncDeletedWater(
        entryID: UUID
    ) async {
        syncedDeletedWaterCount += 1
        lastDeletedEntryID = entryID
    }
    
    func syncUpdatedWater(
        amountInMilliliters: Int,
        date: Date,
        entryID: UUID
    ) async {
        syncedUpdatedWaterCount += 1
        lastUpdatedAmount = amountInMilliliters
        lastUpdatedDate = date
        lastUpdatedEntryID = entryID
    }
}
