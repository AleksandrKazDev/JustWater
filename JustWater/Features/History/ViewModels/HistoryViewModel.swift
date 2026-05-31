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
    
    private let storageService: WaterStorageServicing
    private let goalStorageService: WaterGoalStorageServicing
    private let hapticService: HapticServicing
    private let errorReporter: ErrorReporting
    
    // MARK: - State
    
    var selectedPeriod: HistoryPeriod = .day
    
    var dayReferenceDate = Date.now
    var weekReferenceDate = Date.now
    var monthReferenceDate = Date.now
    var yearReferenceDate = Date.now
    
    var analytics: HistoryAnalytics?
    
    private(set) var pendingUndoAction: WaterEntryUndoAction?
    
    var undoBannerMessage: String {
        pendingUndoAction?.message ?? ""
    }
    
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
    
    var displayDailyGoal: Int {
        do {
            return try goalStorageService.goal(
                for: referenceDate
            )
        } catch {
            errorReporter.report(
                error,
                context: "Failed to fetch display daily goal"
            )
            return AppSettingsStorage.dailyGoal
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
    
    init(
        storageService: WaterStorageServicing,
        goalStorageService: WaterGoalStorageServicing,
        hapticService: HapticServicing,
        errorReporter: ErrorReporting
    ) {
        self.storageService = storageService
        self.goalStorageService = goalStorageService
        self.hapticService = hapticService
        self.errorReporter = errorReporter
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
            
            let dailyGoalProvider: (Date) -> Int = { [goalStorageService] date in
                do {
                    return try goalStorageService.goal(
                        for: date
                    )
                } catch {
                    self.errorReporter.report(
                        error,
                        context: "Failed to fetch goal for history date"
                    )
                    return AppSettingsStorage.dailyGoal
                }
            }
            
            analytics = HistoryAnalyticsService.makeAnalytics(
                period: selectedPeriod,
                entries: entries,
                dailyGoalProvider: dailyGoalProvider,
                referenceDate: referenceDate
            )
        } catch {
            errorReporter.report(
                error,
                context: "Failed to load history analytics"
            )
        }
    }
    
    func calendarDayStates(
        for monthDate: Date
    ) -> [Date: HistoryCalendarDayState] {
        let calendar = Calendar.current
        
        guard let monthInterval = calendar.dateInterval(
            of: .month,
            for: monthDate
        ) else {
            return [:]
        }
        
        do {
            let entries = try storageService.fetchEntries(
                for: .month,
                referenceDate: monthDate
            )
            
            let groupedEntries = Dictionary(
                grouping: entries
            ) { entry in
                calendar.startOfDay(
                    for: entry.date
                )
            }
            
            let goalsByDay = try goalStorageService.goalsByDay(
                from: monthInterval.start,
                to: monthInterval.end
            )
            
            var result: [Date: HistoryCalendarDayState] = [:]
            
            for (date, entriesForDate) in groupedEntries {
                let totalAmount = entriesForDate.reduce(0) {
                    $0 + $1.amount
                }
                
                guard totalAmount > 0 else {
                    continue
                }
                
                let goal = goalsByDay[date] ?? AppSettingsStorage.dailyGoal
                
                result[date] = HistoryCalendarDayState(
                    totalAmount: totalAmount,
                    goal: goal
                )
            }
            
            return result
        } catch {
            errorReporter.report(
                error,
                context: "Failed to load calendar day states"
            )
            
            return [:]
        }
    }
    
    func deleteEntry(
        _ entry: WaterEntry
    ) {
        do {
            let snapshot = WaterEntrySnapshot(
                entry: entry
            )
            
            try storageService.deleteEntry(
                id: entry.id
            )
            
            pendingUndoAction = .deleted(snapshot)
            
            loadAnalytics()
            hapticService.lightImpact()
        } catch {
            errorReporter.report(
                error,
                context: "Failed to delete history entry"
            )
        }
    }
    
    func addEntry(
        amount: Int,
        date: Date,
        drinkType: DrinkType = .water
    ) {
        do {
            let entry = try storageService.saveEntry(
                amount: amount,
                date: date,
                drinkType: drinkType
            )
            
            pendingUndoAction = .added(
                WaterEntrySnapshot(
                    entry: entry
                )
            )
            
            loadAnalytics()
            hapticService.success()
        } catch {
            errorReporter.report(
                error,
                context: "Failed to add history entry"
            )
        }
    }
    
    func updateEntry(
        _ entry: WaterEntry,
        amount: Int,
        date: Date,
        drinkType: DrinkType
    ) {
        do {
            try storageService.updateEntry(
                id: entry.id,
                amount: amount,
                date: date,
                drinkType: drinkType
            )
            
            loadAnalytics()
            HapticService.success()
        } catch {
            errorReporter.report(
                error,
                context: "Failed to update history entry"
            )
        }
    }
    
    func undoLastAction() {
        guard let pendingUndoAction else { return }
        
        do {
            switch pendingUndoAction {
            case .added(let snapshot):
                try storageService.deleteEntry(
                    id: snapshot.id
                )
                
            case .deleted(let snapshot):
                try storageService.restoreEntry(
                    from: snapshot
                )
            }
            
            self.pendingUndoAction = nil
            
            loadAnalytics()
            hapticService.warning()
        } catch {
            errorReporter.report(
                error,
                context: "Failed to undo history action"
            )
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
