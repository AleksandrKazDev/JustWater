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
    
    var dayReferenceDate = Date.now
    var weekReferenceDate = Date.now
    var monthReferenceDate = Date.now
    var yearReferenceDate = Date.now
    
    var analytics: HistoryAnalytics?
    
    // MARK: - Computed Properties
    
    var referenceDate: Date {
        switch selectedPeriod {
        case .day:
            return dayReferenceDate
            
        case .week:
            return weekReferenceDate
            
        case .month:
            return monthReferenceDate
            
        case .year:
            return yearReferenceDate
        }
    }
    
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
            
            let endDate = calendar.date(
                byAdding: .day,
                value: -1,
                to: weekInterval.end
            ) ?? weekInterval.end
            
            let end = endDate.formatted(
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
    
    func selectPeriod(
        _ period: HistoryPeriod
    ) {
        selectedPeriod = period
        
        loadAnalytics()
    }
    
    func selectReferenceDate(
        _ date: Date
    ) {
        setReferenceDate(date)
        
        loadAnalytics()
    }
    
    func showPreviousPeriod() {
        shiftPeriod(by: -1)
    }
    
    func showNextPeriod() {
        shiftPeriod(by: 1)
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
            print("Failed to load history analytics: \(error)")
        }
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
    
    func addEntry(
        amount: Int,
        date: Date,
        drinkType: DrinkType = .water
    ) {
        do {
            try storageService.saveEntry(
                amount: amount,
                date: date,
                drinkType: drinkType
            )
            
            loadAnalytics()
            HapticService.success()
        } catch {
            print("Failed to add history entry: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func setReferenceDate(
        _ date: Date
    ) {
        switch selectedPeriod {
        case .day:
            dayReferenceDate = date
            
        case .week:
            weekReferenceDate = date
            
        case .month:
            monthReferenceDate = date
            
        case .year:
            yearReferenceDate = date
        }
    }
    
    private func shiftPeriod(
        by value: Int
    ) {
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
        
        let newDate = calendar.date(
            byAdding: component,
            value: value,
            to: referenceDate
        ) ?? referenceDate
        
        setReferenceDate(newDate)
        
        loadAnalytics()
    }
}
