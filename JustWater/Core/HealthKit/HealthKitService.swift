//
//  HealthKitService.swift
//  JustWater
//
//  Created by сонный on 14.06.2026.
//

import Foundation
import HealthKit

protocol HealthKitServicing {
    var isHealthDataAvailable: Bool { get }
    
    func requestAuthorization() async throws
    func saveWater(
        amountInMilliliters: Int,
        date: Date,
        entryID: UUID
    ) async throws
    
    func deleteWaterSample(
        entryID: UUID
    ) async throws
}

final class HealthKitService: HealthKitServicing {
    
    // MARK: - Constants
    
    private enum MetadataKey {
        static let justWaterEntryID = "JustWaterEntryID"
    }
    
    // MARK: - Properties
    
    private let healthStore = HKHealthStore()
    
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async throws {
        guard isHealthDataAvailable else {
            throw HealthKitServiceError.healthDataUnavailable
        }
        
        guard let waterType = HKObjectType.quantityType(
            forIdentifier: .dietaryWater
        ) else {
            throw HealthKitServiceError.waterTypeUnavailable
        }
        
        try await healthStore.requestAuthorization(
            toShare: [waterType],
            read: []
        )
    }
    
    // MARK: - Save
    
    func saveWater(
        amountInMilliliters: Int,
        date: Date,
        entryID: UUID
    ) async throws {
        guard isHealthDataAvailable else {
            throw HealthKitServiceError.healthDataUnavailable
        }
        
        guard amountInMilliliters > 0 else {
            throw HealthKitServiceError.invalidWaterAmount
        }
        
        guard let waterType = HKQuantityType.quantityType(
            forIdentifier: .dietaryWater
        ) else {
            throw HealthKitServiceError.waterTypeUnavailable
        }
        
        let quantity = HKQuantity(
            unit: .literUnit(with: .milli),
            doubleValue: Double(amountInMilliliters)
        )
        
        let sample = HKQuantitySample(
            type: waterType,
            quantity: quantity,
            start: date,
            end: date,
            metadata: [
                MetadataKey.justWaterEntryID: entryID.uuidString
            ]
        )
        
        try await healthStore.save(sample)
    }
    
    // MARK: - Delete
    
    func deleteWaterSample(
        entryID: UUID
    ) async throws {
        guard isHealthDataAvailable else {
            throw HealthKitServiceError.healthDataUnavailable
        }
        
        guard let waterType = HKQuantityType.quantityType(
            forIdentifier: .dietaryWater
        ) else {
            throw HealthKitServiceError.waterTypeUnavailable
        }
        
        let predicate = HKQuery.predicateForObjects(
            withMetadataKey: MetadataKey.justWaterEntryID,
            allowedValues: [entryID.uuidString]
        )
        
        try await healthStore.deleteObjects(
            of: waterType,
            predicate: predicate
        )
    }
}
