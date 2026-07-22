//
//  HistoryViewModelTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
@testable import JustWater

@MainActor
final class HistoryViewModelTests: XCTestCase {
    
    // MARK: - Delete
    
    func testDeleteEntry_deletesEntryAndCreatesUndoMessage() {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 250,
            date: Date(),
            drinkType: .coffee
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let sut = makeSUT(
            storageService: storageService
        )
        
        // Act
        sut.deleteEntry(entry)
        
        // Assert
        XCTAssertTrue(
            storageService.entries.isEmpty
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            expectedDeletedMessage(for: .coffee)
        )
    }
    
    func testDeleteEntry_syncsDeletedWaterWithAppleHealth() async {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 250,
            date: Date(),
            drinkType: .coffee
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let healthSyncService = TestHealthSyncService()
        
        let sut = makeSUT(
            storageService: storageService,
            healthSyncService: healthSyncService
        )
        
        // Act
        sut.deleteEntry(entry)
        
        await Task.yield()
        
        // Assert
        XCTAssertEqual(
            healthSyncService.syncedDeletedWaterCount,
            1
        )
        
        XCTAssertEqual(
            healthSyncService.lastDeletedEntryID,
            entry.id
        )
    }
    
    // MARK: - Undo Delete
    
    func testUndoLastAction_afterDeletingEntry_restoresEntry() {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 400,
            date: Date(),
            drinkType: .tea
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let sut = makeSUT(
            storageService: storageService
        )
        
        sut.deleteEntry(entry)
        
        // Act
        sut.undoLastAction()
        
        // Assert
        XCTAssertEqual(
            storageService.entries.count,
            1
        )
        
        XCTAssertEqual(
            storageService.entries.first?.id,
            entry.id
        )
        
        XCTAssertEqual(
            storageService.entries.first?.amount,
            400
        )
        
        XCTAssertEqual(
            storageService.entries.first?.drinkType,
            .tea
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            ""
        )
    }
    
    func testUndoLastAction_afterDeletingEntry_syncsAddedWaterWithAppleHealth() async {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 400,
            date: Date(),
            drinkType: .tea
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let healthSyncService = TestHealthSyncService()
        
        let sut = makeSUT(
            storageService: storageService,
            healthSyncService: healthSyncService
        )
        
        sut.deleteEntry(entry)
        
        await Task.yield()
        
        // Act
        sut.undoLastAction()
        
        await Task.yield()
        
        // Assert
        XCTAssertEqual(
            healthSyncService.syncedAddedWaterCount,
            1
        )
        
        XCTAssertEqual(
            healthSyncService.lastAddedAmount,
            entry.amount
        )
        
        XCTAssertEqual(
            healthSyncService.lastAddedEntryID,
            entry.id
        )
    }
    
    // MARK: - Period Selection
    
    func testSelectPeriod_updatesSelectedPeriod() {
        // Arrange
        let storageService = TestWaterStorageService()
        let sut = makeSUT(
            storageService: storageService
        )
        
        // Act
        sut.selectPeriod(.month)
        
        // Assert
        XCTAssertEqual(
            sut.selectedPeriod,
            .month
        )
    }
    
    func testSelectReferenceDate_whenDaySelected_updatesDayReferenceDate() {
        // Arrange
        let storageService = TestWaterStorageService()
        let sut = makeSUT(
            storageService: storageService
        )
        
        let selectedDate = makeDate(
            year: 2026,
            month: 5,
            day: 20
        )
        
        sut.selectPeriod(.day)
        
        // Act
        sut.selectReferenceDate(selectedDate)
        
        // Assert
        XCTAssertEqual(
            sut.dayReferenceDate,
            selectedDate
        )
        
        XCTAssertEqual(
            sut.referenceDate,
            selectedDate
        )
    }
    
    func testSelectReferenceDate_whenMonthSelected_updatesMonthReferenceDate() {
        // Arrange
        let storageService = TestWaterStorageService()
        let sut = makeSUT(
            storageService: storageService
        )
        
        let selectedDate = makeDate(
            year: 2026,
            month: 8,
            day: 10
        )
        
        sut.selectPeriod(.month)
        
        // Act
        sut.selectReferenceDate(selectedDate)
        
        // Assert
        XCTAssertEqual(
            sut.monthReferenceDate,
            selectedDate
        )
        
        XCTAssertEqual(
            sut.referenceDate,
            selectedDate
        )
    }
    
    // MARK: - Period Navigation
    
    func testShowPreviousPeriod_whenDaySelected_movesReferenceDateOneDayBack() {
        // Arrange
        let storageService = TestWaterStorageService()
        let sut = makeSUT(
            storageService: storageService
        )
        
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        sut.selectPeriod(.day)
        sut.selectReferenceDate(referenceDate)
        
        let expectedDate = Calendar.current.date(
            byAdding: .day,
            value: -1,
            to: referenceDate
        )
        
        // Act
        sut.showPreviousPeriod()
        
        // Assert
        XCTAssertEqual(
            sut.referenceDate,
            expectedDate
        )
    }
    
    func testShowNextPeriod_whenWeekSelected_movesReferenceDateOneWeekForward() {
        // Arrange
        let storageService = TestWaterStorageService()
        let sut = makeSUT(
            storageService: storageService
        )
        
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        sut.selectPeriod(.week)
        sut.selectReferenceDate(referenceDate)
        
        let expectedDate = Calendar.current.date(
            byAdding: .weekOfYear,
            value: 1,
            to: referenceDate
        )
        
        // Act
        sut.showNextPeriod()
        
        // Assert
        XCTAssertEqual(
            sut.referenceDate,
            expectedDate
        )
    }
    
    func testShowNextPeriod_whenMonthSelected_movesReferenceDateOneMonthForward() {
        // Arrange
        let storageService = TestWaterStorageService()
        let sut = makeSUT(
            storageService: storageService
        )
        
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        sut.selectPeriod(.month)
        sut.selectReferenceDate(referenceDate)
        
        let expectedDate = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: referenceDate
        )
        
        // Act
        sut.showNextPeriod()
        
        // Assert
        XCTAssertEqual(
            sut.referenceDate,
            expectedDate
        )
    }
    
    func testShowPreviousPeriod_whenYearSelected_movesReferenceDateOneYearBack() {
        // Arrange
        let storageService = TestWaterStorageService()
        let sut = makeSUT(
            storageService: storageService
        )
        
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        sut.selectPeriod(.year)
        sut.selectReferenceDate(referenceDate)
        
        let expectedDate = Calendar.current.date(
            byAdding: .year,
            value: -1,
            to: referenceDate
        )
        
        // Act
        sut.showPreviousPeriod()
        
        // Assert
        XCTAssertEqual(
            sut.referenceDate,
            expectedDate
        )
    }
    
    // MARK: - Add Entry
    
    func testAddEntry_savesEntryAndReloadsAnalytics() {
        // Arrange
        let storageService = TestWaterStorageService()
        let hapticService = TestHapticService()
        
        let sut = makeSUT(
            storageService: storageService,
            goalStorageService: TestWaterGoalStorageService(),
            hapticService: hapticService,
            errorReporter: TestErrorReporter()
        )
        
        let date = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        sut.selectPeriod(.day)
        sut.selectReferenceDate(date)
        
        // Act
        sut.addEntry(
            amount: 450,
            date: date,
            drinkType: .juice
        )
        
        // Assert
        XCTAssertEqual(
            storageService.entries.count,
            1
        )
        
        XCTAssertEqual(
            storageService.entries.first?.amount,
            450
        )
        
        XCTAssertEqual(
            storageService.entries.first?.date,
            date
        )
        
        XCTAssertEqual(
            storageService.entries.first?.drinkType,
            .juice
        )
        
        XCTAssertEqual(
            sut.analytics?.statistics.totalAmount,
            450
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            expectedAddedMessage(for: .juice)
        )
        
        XCTAssertEqual(
            hapticService.successCallCount,
            1
        )
    }
    
    func testAddEntry_syncsAddedWaterWithAppleHealth() async {
        // Arrange
        let storageService = TestWaterStorageService()
        let healthSyncService = TestHealthSyncService()
        
        let sut = makeSUT(
            storageService: storageService,
            healthSyncService: healthSyncService
        )
        
        let date = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        // Act
        sut.addEntry(
            amount: 450,
            date: date,
            drinkType: .juice
        )
        
        await Task.yield()
        
        // Assert
        XCTAssertEqual(
            healthSyncService.syncedAddedWaterCount,
            1
        )
        
        XCTAssertEqual(
            healthSyncService.lastAddedAmount,
            450
        )
        
        XCTAssertEqual(
            healthSyncService.lastAddedEntryID,
            storageService.entries.first?.id
        )
    }

    func testUndoLastAction_whileAddedEntrySyncIsPending_waitsForSaveBeforeDelete() async {
        // Arrange
        let storageService = TestWaterStorageService()
        let healthSyncService = ControllableAddHealthSyncService()
        let sut = makeSUT(
            storageService: storageService,
            healthSyncService: healthSyncService
        )

        sut.addEntry(
            amount: 450,
            date: Date(),
            drinkType: .juice
        )

        await fulfillment(
            of: [healthSyncService.saveStarted],
            timeout: 1
        )

        let entryID = storageService.entries.first?.id

        // Act
        sut.undoLastAction()

        for _ in 0..<10 where healthSyncService.deleteCallCount == 0 {
            await Task.yield()
        }

        // Assert
        XCTAssertEqual(healthSyncService.deleteCallCount, 0)
        XCTAssertTrue(storageService.entries.isEmpty)

        healthSyncService.completeSave()

        await fulfillment(
            of: [
                healthSyncService.saveCompleted,
                healthSyncService.deleteCompleted
            ],
            timeout: 1
        )

        XCTAssertEqual(
            healthSyncService.events,
            [
                .saveStarted(entryID),
                .saveCompleted(entryID),
                .delete(entryID)
            ]
        )
        XCTAssertEqual(healthSyncService.deleteCallCount, 1)
        XCTAssertEqual(healthSyncService.savedEntryID, entryID)
        XCTAssertEqual(healthSyncService.deletedEntryID, entryID)
    }

    func testAddEntry_withoutUndo_completesSaveWithoutDelete() async {
        // Arrange
        let storageService = TestWaterStorageService()
        let healthSyncService = ControllableAddHealthSyncService()
        let sut = makeSUT(
            storageService: storageService,
            healthSyncService: healthSyncService
        )

        // Act
        sut.addEntry(
            amount: 450,
            date: Date(),
            drinkType: .juice
        )

        await fulfillment(
            of: [healthSyncService.saveStarted],
            timeout: 1
        )

        healthSyncService.completeSave()

        await fulfillment(
            of: [healthSyncService.saveCompleted],
            timeout: 1
        )

        for _ in 0..<10 {
            await Task.yield()
        }

        // Assert
        XCTAssertEqual(healthSyncService.deleteCallCount, 0)
        XCTAssertEqual(storageService.entries.count, 1)
    }
    
    // MARK: - Update Entry
    
    func testUpdateEntry_updatesEntryAndReloadsAnalytics() {
        // Arrange
        let id = UUID()
        
        let originalDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let updatedDate = makeDate(
            year: 2026,
            month: 5,
            day: 26
        )
        
        let entry = WaterEntry(
            id: id,
            amount: 200,
            date: originalDate,
            drinkType: .water
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let sut = makeSUT(
            storageService: storageService
        )
        
        sut.selectPeriod(.day)
        sut.selectReferenceDate(updatedDate)
        
        // Act
        sut.updateEntry(
            entry,
            amount: 700,
            date: updatedDate,
            drinkType: .coffee
        )
        
        // Assert
        XCTAssertEqual(
            storageService.entries.count,
            1
        )
        
        XCTAssertEqual(
            storageService.entries.first?.id,
            id
        )
        
        XCTAssertEqual(
            storageService.entries.first?.amount,
            700
        )
        
        XCTAssertEqual(
            storageService.entries.first?.date,
            updatedDate
        )
        
        XCTAssertEqual(
            storageService.entries.first?.drinkType,
            .coffee
        )
        
        XCTAssertEqual(
            sut.analytics?.statistics.totalAmount,
            700
        )
    }
    
    func testUpdateEntry_syncsUpdatedWaterWithAppleHealth() async {
        // Arrange
        let id = UUID()
        
        let originalDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let updatedDate = makeDate(
            year: 2026,
            month: 5,
            day: 26
        )
        
        let entry = WaterEntry(
            id: id,
            amount: 200,
            date: originalDate,
            drinkType: .water
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let healthSyncService = TestHealthSyncService()
        
        let sut = makeSUT(
            storageService: storageService,
            healthSyncService: healthSyncService
        )
        
        // Act
        sut.updateEntry(
            entry,
            amount: 700,
            date: updatedDate,
            drinkType: .coffee
        )
        
        await Task.yield()
        
        // Assert
        XCTAssertEqual(
            healthSyncService.syncedUpdatedWaterCount,
            1
        )
        
        XCTAssertEqual(
            healthSyncService.lastUpdatedAmount,
            700
        )
        
        XCTAssertEqual(
            healthSyncService.lastUpdatedEntryID,
            id
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        storageService: TestWaterStorageService
    ) -> HistoryViewModel {
        HistoryViewModel(
            storageService: storageService,
            goalStorageService: TestWaterGoalStorageService(),
            streakDayService: TestHydrationStreakDayService(),
            hapticService: TestHapticService(),
            errorReporter: TestErrorReporter(),
            healthSyncService: TestHealthSyncService()
        )
    }
    
    private func makeSUT(
        storageService: TestWaterStorageService,
        goalStorageService: TestWaterGoalStorageService
    ) -> HistoryViewModel {
        HistoryViewModel(
            storageService: storageService,
            goalStorageService: goalStorageService,
            streakDayService: TestHydrationStreakDayService(),
            hapticService: TestHapticService(),
            errorReporter: TestErrorReporter(),
            healthSyncService: TestHealthSyncService()
        )
    }
    
    private func makeSUT(
        storageService: TestWaterStorageService,
        goalStorageService: TestWaterGoalStorageService,
        hapticService: TestHapticService,
        errorReporter: TestErrorReporter
    ) -> HistoryViewModel {
        HistoryViewModel(
            storageService: storageService,
            goalStorageService: goalStorageService,
            streakDayService: TestHydrationStreakDayService(),
            hapticService: hapticService,
            errorReporter: errorReporter,
            healthSyncService: TestHealthSyncService()
        )
    }
    
    private func makeSUT(
        storageService: TestWaterStorageService,
        healthSyncService: HealthSyncServicing
    ) -> HistoryViewModel {
        HistoryViewModel(
            storageService: storageService,
            goalStorageService: TestWaterGoalStorageService(),
            streakDayService: TestHydrationStreakDayService(),
            hapticService: TestHapticService(),
            errorReporter: TestErrorReporter(),
            healthSyncService: healthSyncService
        )
    }

    private final class ControllableAddHealthSyncService: HealthSyncServicing {

        enum Event: Equatable {
            case saveStarted(UUID?)
            case saveCompleted(UUID?)
            case delete(UUID?)
        }

        let saveStarted = XCTestExpectation(description: "Health sync save started")
        let saveCompleted = XCTestExpectation(description: "Health sync save completed")
        let deleteCompleted = XCTestExpectation(description: "Health sync delete completed")

        private(set) var events: [Event] = []
        private(set) var deleteCallCount = 0
        private(set) var savedEntryID: UUID?
        private(set) var deletedEntryID: UUID?

        private var saveContinuation: CheckedContinuation<Void, Never>?

        func syncAddedWater(
            amountInMilliliters: Int,
            date: Date,
            entryID: UUID
        ) async {
            savedEntryID = entryID
            events.append(.saveStarted(entryID))

            await withCheckedContinuation { continuation in
                saveContinuation = continuation
                saveStarted.fulfill()
            }

            events.append(.saveCompleted(entryID))
            saveCompleted.fulfill()
        }

        func syncDeletedWater(
            entryID: UUID
        ) async {
            deleteCallCount += 1
            deletedEntryID = entryID
            events.append(.delete(entryID))
            deleteCompleted.fulfill()
        }

        func syncUpdatedWater(
            amountInMilliliters: Int,
            date: Date,
            entryID: UUID
        ) async {}

        func completeSave() {
            saveContinuation?.resume()
            saveContinuation = nil
        }
    }
    
    private final class TestHydrationStreakDayService: HydrationStreakDayTracking {
        func markTodayIfEntryIsForToday(
            entryDate: Date
        ) throws {}
        
        func fetchStreakDays() throws -> Set<Date> {
            []
        }
    }
    
    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12,
        minute: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        
        return components.date!
    }
    
    private func expectedAddedMessage(
        for drinkType: DrinkType
    ) -> String {
        String(
            format: String(localized: "undo.added"),
            drinkType.title
        )
    }
    
    private func expectedDeletedMessage(
        for drinkType: DrinkType
    ) -> String {
        String(
            format: String(localized: "undo.deleted"),
            drinkType.title
        )
    }
}
