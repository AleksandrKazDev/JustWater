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
            print("❌ WidgetSnapshotStorage: App Group UserDefaults unavailable")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(snapshot)
            userDefaults.set(data, forKey: snapshotKey)
            userDefaults.synchronize()
            
            print(
                """
                ✅ Widget snapshot saved:
                consumedWater: \(snapshot.consumedWater)
                dailyGoal: \(snapshot.dailyGoal)
                unit: \(snapshot.measurementUnitRawValue)
                """
            )
        } catch {
            assertionFailure("Failed to encode widget snapshot: \(error)")
        }
    }
    
    static func load() -> WidgetHydrationSnapshot {
        guard let userDefaults = UserDefaults(
            suiteName: appGroupIdentifier
        ) else {
            print("❌ WidgetSnapshotStorage: App Group UserDefaults unavailable")
            return .empty
        }
        
        guard let data = userDefaults.data(forKey: snapshotKey) else {
            print("⚠️ WidgetSnapshotStorage: No snapshot found")
            return .empty
        }
        
        do {
            let snapshot = try JSONDecoder().decode(
                WidgetHydrationSnapshot.self,
                from: data
            )
            
            print(
                """
                ✅ Widget snapshot loaded:
                consumedWater: \(snapshot.consumedWater)
                dailyGoal: \(snapshot.dailyGoal)
                unit: \(snapshot.measurementUnitRawValue)
                """
            )
            
            return snapshot
        } catch {
            assertionFailure("Failed to decode widget snapshot: \(error)")
            return .empty
        }
    }
}
