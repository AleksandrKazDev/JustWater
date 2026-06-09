//
//  WidgetSnapshotService.swift
//  JustWater
//
//  Created by сонный on 09.06.2026.
//

import Foundation
import WidgetKit

protocol WidgetSnapshotServicing {
    
    func updateSnapshot(
        hydrationState: HydrationState
    )
}

struct WidgetSnapshotService: WidgetSnapshotServicing {
    
    func updateSnapshot(
        hydrationState: HydrationState
    ) {
        let snapshot = WidgetHydrationSnapshot(
            consumedWater: hydrationState.consumedWater,
            dailyGoal: hydrationState.dailyGoal,
            measurementUnitRawValue: AppSettingsStorage.measurementUnit.rawValue,
            date: .now,
            updatedAt: .now
        )
        
        WidgetSnapshotStorage.save(snapshot)
        
        WidgetCenter.shared.reloadTimelines(
            ofKind: WidgetConstants.kind
        )
    }
}
