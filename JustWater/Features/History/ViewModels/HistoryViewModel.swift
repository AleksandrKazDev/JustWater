//
//  HistoryViewModel.swift
//  JustWater
//
//  Created by сонный on 15.05.2026.
//

import Foundation

@Observable
@MainActor
final class HistoryViewModel {
    
    // MARK: - Dependencies
    
    private let storageService: WaterStorageService
    
    // MARK: - State
    
    var selectedPeriod: HistoryPeriod = .day
    var analytics: HistoryAnalytics?
    
    // MARK: - Initializer
    
    init(storageService: WaterStorageService) {
        self.storageService = storageService
        loadAnalytics()
    }
    
    // MARK: - Public Methods
    
    func selectPeriod(_ period: HistoryPeriod) {
        selectedPeriod = period
        loadAnalytics()
    }
    
    func loadAnalytics() {
        do {
            let entries = try storageService.fetchEntries(
                for: selectedPeriod
            )
            
            analytics = HistoryAnalyticsService.makeAnalytics(
                period: selectedPeriod,
                entries: entries,
                dailyGoal: AppSettingsStorage.dailyGoal
            )
        } catch {
            print(
                "Failed to load history analytics: \(error)"
            )
        }
    }
}
