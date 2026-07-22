//
//  HistoryViewModel.swift
//  JustWater
//
//  Created by сонный on 15.05.2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class HistoryViewModel {
    
    // MARK: - Dependencies
    
    private let storageService: WaterStorageServicing
    private let goalStorageService: WaterGoalStorageServicing
    private let streakDayService: HydrationStreakDayTracking
    private let streakCalculator: HydrationStreakCalculating
    private let dateProvider: DateProviding
    private let hapticService: HapticServicing
    private let errorReporter: ErrorReporting
    private let healthSyncService: HealthSyncServicing
    private let calendar: Calendar
    @ObservationIgnored private var hasLoadedInitialAnalytics = false
    @ObservationIgnored private var pendingAddedWaterSyncs: [UUID: PendingAddedWaterSync] = [:]
    
    // MARK: - State
    
    var selectedPeriod: HistoryPeriod = .day
    
    var dayReferenceDate = Date.now
    var weekReferenceDate = Date.now
    var monthReferenceDate = Date.now
    var yearReferenceDate = Date.now
    
    var analytics: HistoryAnalytics?
    
    private(set) var currentStreak: Int = 0
    private(set) var displayDailyGoal: Int = AppSettingsStorage.dailyGoal
    private(set) var pendingUndoAction: WaterEntryUndoAction?
    private(set) var measurementUnit = AppSettingsStorage.measurementUnit
    
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
    
    var periodTitle: String {
        switch selectedPeriod {
        case .day:
            return referenceDate.formatted(
                .dateTime
                    .day()
                    .month(.wide)
            )
            
        case .week:
            guard let weekInterval = calendar.dateInterval(
                of: .weekOfYear,
                for: referenceDate
            ) else {
                return ""
            }
            
            let start = removingMonthAbbreviationDot(
                from: weekInterval.start.formatted(
                    .dateTime.day().month(.abbreviated)
                )
            )
            
            let endDate = calendar.date(
                byAdding: .day,
                value: -1,
                to: weekInterval.end
            ) ?? weekInterval.end
            
            let end = removingMonthAbbreviationDot(
                from: endDate.formatted(
                    .dateTime.day().month(.abbreviated)
                )
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
    
    private func removingMonthAbbreviationDot(
        from string: String
    ) -> String {
        string.replacingOccurrences(of: ".", with: "")
    }
    
    // MARK: - Initializer
    
    init(
        storageService: WaterStorageServicing,
        goalStorageService: WaterGoalStorageServicing,
        streakDayService: HydrationStreakDayTracking,
        streakCalculator: HydrationStreakCalculating = HydrationStreakCalculator(),
        dateProvider: DateProviding = SystemDateProvider(),
        hapticService: HapticServicing,
        errorReporter: ErrorReporting,
        healthSyncService: HealthSyncServicing,
        calendar: Calendar = .current
    ) {
        self.storageService = storageService
        self.goalStorageService = goalStorageService
        self.streakDayService = streakDayService
        self.streakCalculator = streakCalculator
        self.dateProvider = dateProvider
        self.hapticService = hapticService
        self.errorReporter = errorReporter
        self.calendar = calendar
        self.healthSyncService = healthSyncService
    }
    
    // MARK: - Public Methods
    
    func selectPeriod(
        _ period: HistoryPeriod
    ) {
        guard selectedPeriod != period else { return }
        
        selectedPeriod = period
        
        loadAnalytics()
    }
    
    func selectReferenceDate(
        _ date: Date
    ) {
        guard referenceDate != date else { return }
        
        setReferenceDate(date)
        
        loadAnalytics()
    }
    
    func showPreviousPeriod() {
        shiftPeriod(by: -1)
    }
    
    func showNextPeriod() {
        shiftPeriod(by: 1)
    }
    
    func loadInitialAnalyticsIfNeeded() {
        guard !hasLoadedInitialAnalytics else { return }
        
        loadAnalytics()
    }
    
    func loadAnalytics() {
        hasLoadedInitialAnalytics = true
        updateIfNeeded(\.measurementUnit, to: AppSettingsStorage.measurementUnit)
        
        do {
            let interval = dateInterval(
                for: selectedPeriod,
                referenceDate: referenceDate
            )
            
            let entries = try storageService.fetchEntries(
                from: interval.start,
                to: interval.end
            )
            
            let goalsByDay = try goalStorageService.goalsByDay(
                from: interval.start,
                to: interval.end
            )
            
            let newDisplayDailyGoal = goal(
                for: referenceDate,
                in: goalsByDay
            )
            updateIfNeeded(\.displayDailyGoal, to: newDisplayDailyGoal)
            
            let dailyGoalProvider: (Date) -> Int = { date in
                self.goal(
                    for: date,
                    in: goalsByDay
                )
            }
            
            let newAnalytics = HistoryAnalyticsService.makeAnalytics(
                period: selectedPeriod,
                entries: entries,
                dailyGoalProvider: dailyGoalProvider,
                referenceDate: referenceDate
            )
            updateIfNeeded(\.analytics, to: newAnalytics)
            
            reloadCurrentStreak()
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
            
            let goalsByDay = try goalStorageService.goalsByDay(
                from: monthInterval.start,
                to: monthInterval.end
            )
            
            return makeCalendarDayStates(
                entries: entries,
                goalsByDay: goalsByDay
            )
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
            
            Task {
                await healthSyncService.syncDeletedWater(
                    entryID: snapshot.id
                )
            }
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
            
            markStreakDayIfNeeded(
                for: date
            )
            
            pendingUndoAction = .added(
                WaterEntrySnapshot(
                    entry: entry
                )
            )
            
            loadAnalytics()
            hapticService.success()
            
            startAddedWaterSync(for: entry)
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
            hapticService.success()
            
            Task {
                await healthSyncService.syncUpdatedWater(
                    amountInMilliliters: amount,
                    date: date,
                    entryID: entry.id
                )
            }
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

                syncDeletedWaterAfterPendingAdd(
                    entryID: snapshot.id
                )
                
            case .deleted(let snapshot):
                try storageService.restoreEntry(
                    from: snapshot
                )
                
                Task {
                    await healthSyncService.syncAddedWater(
                        amountInMilliliters: snapshot.amount,
                        date: snapshot.date,
                        entryID: snapshot.id
                    )
                }
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
    
    private func reloadCurrentStreak() {
        do {
            let streakDays = try streakDayService.fetchStreakDays()
            
            let newCurrentStreak = streakCalculator.currentStreak(
                streakDays: streakDays,
                currentDate: dateProvider.now,
                calendar: calendar
            )
            
            updateIfNeeded(\.currentStreak, to: newCurrentStreak)
        } catch {
            updateIfNeeded(\.currentStreak, to: 0)
            
            errorReporter.report(
                error,
                context: "Failed to load current streak"
            )
        }
    }
    
    private func markStreakDayIfNeeded(
        for entryDate: Date
    ) {
        do {
            try streakDayService.markTodayIfEntryIsForToday(
                entryDate: entryDate
            )
        } catch {
            errorReporter.report(
                error,
                context: "Failed to mark streak day after adding history entry"
            )
        }
    }
    
    private func makeCalendarDayStates(
        entries: [WaterEntry],
        goalsByDay: [Date: Int]
    ) -> [Date: HistoryCalendarDayState] {
        let groupedEntries = Dictionary(
            grouping: entries
        ) { entry in
            calendar.startOfDay(
                for: entry.date
            )
        }
        
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
    }
    
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
        
        guard referenceDate != newDate else { return }
        
        setReferenceDate(newDate)
        
        loadAnalytics()
    }
    
    private func dateInterval(
        for period: HistoryPeriod,
        referenceDate: Date
    ) -> DateInterval {
        switch period {
        case .day:
            let startDate = calendar.startOfDay(
                for: referenceDate
            )
            
            let endDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: startDate
            ) ?? referenceDate
            
            return DateInterval(
                start: startDate,
                end: endDate
            )
            
        case .week:
            return calendar.dateInterval(
                of: .weekOfYear,
                for: referenceDate
            ) ?? fallbackDateInterval(
                referenceDate: referenceDate
            )
            
        case .month:
            return calendar.dateInterval(
                of: .month,
                for: referenceDate
            ) ?? fallbackDateInterval(
                referenceDate: referenceDate
            )
            
        case .year:
            return calendar.dateInterval(
                of: .year,
                for: referenceDate
            ) ?? fallbackDateInterval(
                referenceDate: referenceDate
            )
        }
    }
    
    private func fallbackDateInterval(
        referenceDate: Date
    ) -> DateInterval {
        let startDate = calendar.startOfDay(
            for: referenceDate
        )
        
        let endDate = calendar.date(
            byAdding: .day,
            value: 1,
            to: startDate
        ) ?? referenceDate
        
        return DateInterval(
            start: startDate,
            end: endDate
        )
    }
    
    private func goal(
        for date: Date,
        in goalsByDay: [Date: Int]
    ) -> Int {
        let startOfDay = calendar.startOfDay(
            for: date
        )
        
        return goalsByDay[startOfDay] ?? AppSettingsStorage.dailyGoal
    }
    
    private func updateIfNeeded<Value: Equatable>(
        _ keyPath: ReferenceWritableKeyPath<HistoryViewModel, Value>,
        to newValue: Value
    ) {
        guard self[keyPath: keyPath] != newValue else { return }
        
        self[keyPath: keyPath] = newValue
    }
}
