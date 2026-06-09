//
//  WidgetSnapshotStorage.swift
//  JustWater
//
//  Created by сонный on 09.06.2026.
//

import Foundation

enum WidgetSnapshotStorage {
    
    private static let appGroupIdentifier = "group.com.alexandrkazdev.JustWater"
    private static let snapshotKey = "widget.hydration.snapshot"
    
    static func save(
        _ snapshot: WidgetHydrationSnapshot
    ) {
        guard let userDefaults = UserDefaults(
            suiteName: appGroupIdentifier
        ) else {
            assertionFailure("App Group UserDefaults is unavailable.")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(snapshot)
            userDefaults.set(data, forKey: snapshotKey)
        } catch {
            assertionFailure("Failed to encode widget snapshot: \(error)")
        }
    }
    
    static func load() -> WidgetHydrationSnapshot {
        guard let userDefaults = UserDefaults(
            suiteName: appGroupIdentifier
        ) else {
            assertionFailure("App Group UserDefaults is unavailable.")
            return .empty
        }
        
        guard let data = userDefaults.data(
            forKey: snapshotKey
        ) else {
            return .empty
        }
        
        do {
            return try JSONDecoder().decode(
                WidgetHydrationSnapshot.self,
                from: data
            )
        } catch {
            assertionFailure("Failed to decode widget snapshot: \(error)")
            return .empty
        }
    }
}
