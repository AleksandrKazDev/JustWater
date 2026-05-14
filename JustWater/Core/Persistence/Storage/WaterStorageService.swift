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
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
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
}
