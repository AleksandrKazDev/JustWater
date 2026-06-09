//
//  HomeViewModel.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation

@MainActor
@Observable
final class HomeViewModel {
    
    private let storageService: WaterStorageServicing
    private let streakDayService: HydrationStreakDayTracking
    private let hapticService: HapticServicing
    private let errorReporter: ErrorReporting
    private let widgetSnapshotService: WidgetSnapshotServicing
    
    
    var hydrationState = HydrationState(
        dailyGoal: AppSettingsStorage.dailyGoal,
        entries: []
    )
    
    private(set) var pendingUndoAction: WaterEntryUndoAction?
    private(set) var measurementUnit = AppSettingsStorage.measurementUnit
    
    var undoBannerMessage: String {
        pendingUndoAction?.message ?? ""
    }
    
    init(
        storageService: WaterStorageServicing,
        streakDayService: HydrationStreakDayTracking,
        hapticService: HapticServicing,
        errorReporter: ErrorReporting,
        widgetSnapshotService: WidgetSnapshotServicing
    ) {
        self.storageService = storageService
        self.streakDayService = streakDayService
        self.hapticService = hapticService
        self.errorReporter = errorReporter
        self.widgetSnapshotService = widgetSnapshotService
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
                
            case .deleted(let snapshot):
                try storageService.restoreEntry(from: snapshot)
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
}
