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
    var referenceDate = Date.now
    var analytics: HistoryAnalytics?
    
    var periodTitle: String {
        switch selectedPeriod {
        case .day:
            return referenceDate.formatted(
                .dateTime
                    .day()
                    .month(.wide)
            )
            
        case .week:
            let calendar = Calendar.current
            
            guard let weekInterval = calendar.dateInterval(
                of: .weekOfYear,
                for: referenceDate
            ) else {
                return ""
            }
            
            let start = weekInterval.start.formatted(
                .dateTime.day().month(.abbreviated)
            )
            
            let end = weekInterval.end.formatted(
                .dateTime.day().month(.abbreviated)
            )
            
            return "\(start) – \(end)"
            
        case .month:
            return referenceDate.formatted(
                .dateTime
                    .month(.wide)
                    .year()
            )
            
        case .year:
            return referenceDate.formatted(
                .dateTime
                    .year()
            )
        }
    }
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
    
    func selectReferenceDate(_ date: Date) {
        referenceDate = date
        loadAnalytics()
    }
    
    func loadAnalytics() {
        do {
            let entries = try storageService.fetchEntries(
                for: selectedPeriod,
                referenceDate: referenceDate
            )
            
            analytics = HistoryAnalyticsService.makeAnalytics(
                period: selectedPeriod,
                entries: entries,
                dailyGoal: AppSettingsStorage.dailyGoal,
                referenceDate: referenceDate
            )
        } catch {
            print(
                "Failed to load history analytics: \(error)"
            )
        }
    }
    private func shiftPeriod(by value: Int) {
        let calendar = Calendar.current
        
        let component: Calendar.Component
        
        switch selectedPeriod {
        case .day:
            component = .day
            
        case .week:
            component = .weekOfYear
            
        case .month:
            component = .month
            
        case .year:
            component = .year
        }
        
        referenceDate = calendar.date(
            byAdding: component,
            value: value,
            to: referenceDate
        ) ?? referenceDate
        
        loadAnalytics()
    }
    
    func showPreviousPeriod() {
        shiftPeriod(by: -1)
    }

    func showNextPeriod() {
        shiftPeriod(by: 1)
    }
    
    func deleteEntry(_ entry: WaterEntry) {
        do {
            try storageService.deleteEntry(id: entry.id)
            loadAnalytics()
            HapticService.lightImpact()
        } catch {
            print("Failed to delete history entry: \(error)")
        }
    }
}
