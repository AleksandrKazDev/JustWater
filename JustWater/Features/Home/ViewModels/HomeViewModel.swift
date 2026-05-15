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
    
    private let storageService: WaterStorageService
    
    var hydrationState = HydrationState(
        dailyGoal: 2000,
        entries: []
    )
    
    private(set) var lastAddedEntry: WaterEntry?
    
    init(storageService: WaterStorageService) {
        self.storageService = storageService
        loadEntries()
    }
    
    func loadEntries() {
        do {
            let entries = try storageService.fetchEntries(for: Date.now)
            hydrationState.entries = entries
        } catch {
            print("Failed to fetch water entries: \(error)")
        }
    }
    
    func addWater(_ amount: Int) {
        do {
            try storageService.saveEntry(amount: amount)
            loadEntries()
            lastAddedEntry = hydrationState.entries.first
            HapticService.success()
        } catch {
            print("Failed to save water entry: \(error)")
        }
    }
    
    func deleteEntry(_ entry: WaterEntry) {
        do {
            try storageService.deleteEntry(id: entry.id)
            loadEntries()
            HapticService.lightImpact()
        } catch {
            print("Failed to delete water entry: \(error)")
        }
    }
    
    func undoLastAdd() {
        guard let lastAddedEntry else { return }
        
        deleteEntry(lastAddedEntry)
        self.lastAddedEntry = nil
        HapticService.warning()
    }
}
