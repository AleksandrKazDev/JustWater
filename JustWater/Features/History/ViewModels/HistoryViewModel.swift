//
//  HistoryViewModel.swift
//  JustWater
//
//  Created by сонный on 15.05.2026.
//

import Foundation

@MainActor
@Observable
final class HistoryViewModel {
    
    // MARK: - Properties
    
    private let storageService: WaterStorageService
    
    var summaries: [DailyHydrationSummary] = []
    
    // MARK: - Initializer
    
    init(storageService: WaterStorageService) {
        self.storageService = storageService
        loadSummaries()
    }
    
    // MARK: - Public Methods
    
    func loadSummaries() {
        do {
            summaries = try storageService.fetchDailySummaries()
        } catch {
            print("Failed to fetch daily summaries: \(error)")
        }
    }
}
