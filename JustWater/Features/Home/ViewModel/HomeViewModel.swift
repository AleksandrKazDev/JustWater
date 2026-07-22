//
//  HomeViewModel.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    
    private let storageService: WaterStorageServicing
    private let streakDayService: HydrationStreakDayTracking
    private let hapticService: HapticServicing
    private let errorReporter: ErrorReporting
    private let widgetSnapshotService: WidgetSnapshotServicing
    private let healthSyncService: HealthSyncServicing
    private let goalAchievementService: GoalAchievementService
    @ObservationIgnored private var pendingAddedWaterSyncs: [UUID: PendingAddedWaterSync] = [:]
    
    
    var hydrationState = HydrationState(
        dailyGoal: AppSettingsStorage.dailyGoal,
        entries: []
    )
    
    private(set) var pendingUndoAction: WaterEntryUndoAction?
    private(set) var measurementUnit = AppSettingsStorage.measurementUnit
    private(set) var goalAchievementEventID: UUID?
    
    var undoBannerMessage: String {
        pendingUndoAction?.message ?? ""
    }
    
    init(
        storageService: WaterStorageServicing,
        streakDayService: HydrationStreakDayTracking,
        hapticService: HapticServicing,
        errorReporter: ErrorReporting,
        widgetSnapshotService: WidgetSnapshotServicing,
        healthSyncService: HealthSyncServicing,
        goalAchievementService: GoalAchievementService = GoalAchievementService()
    ) {
        self.storageService = storageService
        self.streakDayService = streakDayService
        self.hapticService = hapticService
        self.errorReporter = errorReporter
        self.widgetSnapshotService = widgetSnapshotService
        self.healthSyncService = healthSyncService
        self.goalAchievementService = goalAchievementService
    }
    
    func loadEntries() {
        do {
            hydrationState.dailyGoal = AppSettingsStorage.dailyGoal
            measurementUnit = AppSettingsStorage.measurementUnit
            
            let entries = try storageService.fetchEntries(
                for: Date.now
            )
            
            hydrationState.entries = entries
            
            widgetSnapshotService.updateSnapshot(
                hydrationState: hydrationState
            )
            
        } catch {
            errorReporter.report(
                error,
                context: "Failed to fetch water entries"
            )
        }
    }
    
    func addWater(
        _ amount: Int,
        drinkType: DrinkType = .water
    ) {
        let amountBefore = hydrationState.consumedWater
        let dailyGoal = hydrationState.dailyGoal

        do {
            let entryDate = Date()
            
            let entry = try storageService.saveEntry(
                amount: amount,
                date: entryDate,
                drinkType: drinkType
            )
            
            try streakDayService.markTodayIfEntryIsForToday(
                entryDate: entryDate
            )
            
            pendingUndoAction = .added(
                WaterEntrySnapshot(entry: entry)
            )
            
            loadEntries()
            hapticService.success()

            if goalAchievementService.shouldShowCongratulations(
                entryDate: entry.date,
                amountBefore: amountBefore,
                amountAfter: amountBefore + entry.amount,
                dailyGoal: dailyGoal
            ) {
                goalAchievementEventID = UUID()
            }
            
            startAddedWaterSync(for: entry)
        } catch {
            errorReporter.report(
                error,
                context: "Failed to save water entry"
            )
        }
    }
    
    func deleteEntry(_ entry: WaterEntry) {
        do {
            let snapshot = WaterEntrySnapshot(entry: entry)
            
            try storageService.deleteEntry(id: entry.id)
            
            pendingUndoAction = .deleted(snapshot)
            
            loadEntries()
            hapticService.lightImpact()
            
            Task {
                await healthSyncService.syncDeletedWater(
                    entryID: snapshot.id
                )
            }
        } catch {
            errorReporter.report(
                error,
                context: "Failed to delete water entry"
            )
        }
    }
    
    func undoLastAction() {
        guard let pendingUndoAction else { return }
        
        do {
            switch pendingUndoAction {
            case .added(let snapshot):
                try storageService.deleteEntry(id: snapshot.id)

                syncDeletedWaterAfterPendingAdd(
                    entryID: snapshot.id
                )
                
            case .deleted(let snapshot):
                try storageService.restoreEntry(from: snapshot)
                
                Task {
                    await healthSyncService.syncAddedWater(
                        amountInMilliliters: snapshot.amount,
                        date: snapshot.date,
                        entryID: snapshot.id
                    )
                }
            }
            
            self.pendingUndoAction = nil
            
            loadEntries()
            hapticService.warning()
        } catch {
            errorReporter.report(
                error,
                context: "Failed to undo last home action"
            )
        }
    }

    private func startAddedWaterSync(
        for entry: WaterEntry
    ) {
        let operationID = UUID()
        let healthSyncService = healthSyncService
        let task = Task {
            await healthSyncService.syncAddedWater(
                amountInMilliliters: entry.amount,
                date: entry.date,
                entryID: entry.id
            )
        }

        pendingAddedWaterSyncs[entry.id] = PendingAddedWaterSync(
            operationID: operationID,
            task: task
        )

        Task { [weak self] in
            await task.value
            self?.removePendingAddedWaterSync(
                entryID: entry.id,
                operationID: operationID
            )
        }
    }

    private func syncDeletedWaterAfterPendingAdd(
        entryID: UUID
    ) {
        let pendingSave = pendingAddedWaterSyncs.removeValue(
            forKey: entryID
        )
        let healthSyncService = healthSyncService

        Task {
            // HealthKit save is not reliably cancelled, so Undo deletes only after it finishes.
            await pendingSave?.task.value
            await healthSyncService.syncDeletedWater(
                entryID: entryID
            )
        }
    }

    private func removePendingAddedWaterSync(
        entryID: UUID,
        operationID: UUID
    ) {
        guard pendingAddedWaterSyncs[entryID]?.operationID == operationID else {
            return
        }

        pendingAddedWaterSyncs.removeValue(forKey: entryID)
    }

    private struct PendingAddedWaterSync {
        let operationID: UUID
        let task: Task<Void, Never>
    }
}
