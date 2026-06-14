//
//  HealthSyncService.swift
//  JustWater
//
//  Created by сонный on 14.06.2026.
//

import Foundation

@MainActor
protocol HealthSyncServicing {
    func syncAddedWater(
        amountInMilliliters: Int,
        date: Date,
        entryID: UUID
    ) async
    
    func syncDeletedWater(
        entryID: UUID
    ) async
    
    func syncUpdatedWater(
        amountInMilliliters: Int,
        date: Date,
        entryID: UUID
    ) async
}

@MainActor
final class HealthSyncService: HealthSyncServicing {
    
    // MARK: - Dependencies
    
    private let healthKitService: HealthKitServicing
    private let errorReporter: ErrorReporting
    
    // MARK: - Initializer
    
    init(
        healthKitService: HealthKitServicing,
        errorReporter: ErrorReporting
    ) {
        self.healthKitService = healthKitService
        self.errorReporter = errorReporter
    }
    
    // MARK: - Public Methods
    
    func syncAddedWater(
        amountInMilliliters: Int,
        date: Date,
        entryID: UUID
    ) async {
        guard AppSettingsStorage.isHealthSyncEnabled else {
            return
        }
        
        do {
            try await healthKitService.saveWater(
                amountInMilliliters: amountInMilliliters,
                date: date,
                entryID: entryID
            )
        } catch {
            errorReporter.report(
                error,
                context: "Failed to sync added water with Apple Health"
            )
        }
    }
    
    func syncDeletedWater(
        entryID: UUID
    ) async {
        guard AppSettingsStorage.isHealthSyncEnabled else {
            return
        }
        
        do {
            try await healthKitService.deleteWaterSample(
                entryID: entryID
            )
        } catch {
            errorReporter.report(
                error,
                context: "Failed to sync deleted water with Apple Health"
            )
        }
    }
    
    func syncUpdatedWater(
        amountInMilliliters: Int,
        date: Date,
        entryID: UUID
    ) async {
        guard AppSettingsStorage.isHealthSyncEnabled else {
            return
        }
        
        do {
            try await healthKitService.deleteWaterSample(
                entryID: entryID
            )
            
            try await healthKitService.saveWater(
                amountInMilliliters: amountInMilliliters,
                date: date,
                entryID: entryID
            )
        } catch {
            errorReporter.report(
                error,
                context: "Failed to sync updated water with Apple Health"
            )
        }
    }
}
