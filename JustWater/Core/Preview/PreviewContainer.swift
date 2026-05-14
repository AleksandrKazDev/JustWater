//
//  PreviewContainer.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation
import SwiftData

enum PreviewContainer {
    
    @MainActor
    static var shared: ModelContainer {
        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )
        
        do {
            return try ModelContainer(
                for: WaterEntryEntity.self,
                configurations: configuration
            )
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
