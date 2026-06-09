//
//  JustWaterWidgetProvider.swift
//  JustWaterWidgetExtension
//
//  Created by сонный on 10.06.2026.
//

import WidgetKit
import Foundation

struct JustWaterWidgetProvider: TimelineProvider {
    
    // MARK: - Placeholder
    
    func placeholder(
        in context: Context
    ) -> JustWaterWidgetEntry {
        JustWaterWidgetEntry(
            date: .now,
            snapshot: .empty
        )
    }
    
    // MARK: - Snapshot
    
    func getSnapshot(
        in context: Context,
        completion: @escaping (JustWaterWidgetEntry) -> Void
    ) {
        completion(
            JustWaterWidgetEntry(
                date: .now,
                snapshot: currentSnapshot
            )
        )
    }
    
    // MARK: - Timeline
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<JustWaterWidgetEntry>) -> Void
    ) {
        let entry = JustWaterWidgetEntry(
            date: .now,
            snapshot: currentSnapshot
        )
        
        let nextUpdateDate = Calendar.current.date(
            byAdding: .minute,
            value: 30,
            to: .now
        ) ?? .now.addingTimeInterval(1_800)
        
        completion(
            Timeline(
                entries: [entry],
                policy: .after(nextUpdateDate)
            )
        )
    }
    
    // MARK: - Private
    
    private var currentSnapshot: WidgetHydrationSnapshot {
        WidgetSnapshotStorage.load()
            .normalizedForToday()
    }
}
