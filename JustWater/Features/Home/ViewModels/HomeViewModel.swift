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
    
    var hydrationState = HydrationState(
        dailyGoal: AppSettingsStorage.dailyGoal,
        entries: []
    )
    
    private(set) var pendingUndoAction: WaterEntryUndoAction?
    
    var undoBannerMessage: String {
        pendingUndoAction?.message ?? ""
    }
    
    init(storageService: WaterStorageServicing) {
        self.storageService = storageService
        loadEntries()
    }
    
    func loadEntries() {
        do {
            hydrationState.dailyGoal = AppSettingsStorage.dailyGoal
            
            let entries = try storageService.fetchEntries(for: Date.now)
            hydrationState.entries = entries
        } catch {
            print("Failed to fetch water entries: \(error)")
        }
    }
    
    func addWater(
        _ amount: Int,
        drinkType: DrinkType = .water
    ) {
        do {
            let entry = try storageService.saveEntry(
                amount: amount,
                date: Date(),
                drinkType: drinkType
            )
            
            pendingUndoAction = .added(
                WaterEntrySnapshot(entry: entry)
            )
            
            loadEntries()
            HapticService.success()
        } catch {
            print("Failed to save water entry: \(error)")
        }
    }
    
    func deleteEntry(_ entry: WaterEntry) {
        do {
            let snapshot = WaterEntrySnapshot(entry: entry)
            
            try storageService.deleteEntry(id: entry.id)
            
            pendingUndoAction = .deleted(snapshot)
            
            loadEntries()
            HapticService.lightImpact()
        } catch {
            print("Failed to delete water entry: \(error)")
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
            HapticService.warning()
        } catch {
            print("Failed to undo last action: \(error)")
        }
    }
}
