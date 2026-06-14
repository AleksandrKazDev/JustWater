//
//  HomeViewModelTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
@testable import JustWater

@MainActor
final class HomeViewModelTests: XCTestCase {
    
    // MARK: - Add
    
    func testAddWater_addsWaterEntryAndCreatesUndoMessage() {
        // Arrange
        let storageService = TestWaterStorageService()
        let hapticService = TestHapticService()
        let sut = makeSUT(
            storageService: storageService,
            hapticService: hapticService
        )
        
        // Act
        sut.addWater(
            200,
            drinkType: .water
        )
        
        // Assert
        XCTAssertEqual(
            sut.hydrationState.entries.count,
            1
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.amount,
            200
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.drinkType,
            .water
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            expectedAddedMessage(for: .water)
        )
        
        XCTAssertEqual(
            hapticService.successCallCount,
            1
        )
    }
    
    func testAddWater_withCoffee_addsCoffeeEntryAndCreatesUndoMessage() {
        // Arrange
        let storageService = TestWaterStorageService()
        let hapticService = TestHapticService()
        let sut = makeSUT(
            storageService: storageService,
            hapticService: hapticService
        )
        
        // Act
        sut.addWater(
            300,
            drinkType: .coffee
        )
        
        // Assert
        XCTAssertEqual(
            sut.hydrationState.entries.count,
            1
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.amount,
            300
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.drinkType,
            .coffee
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            expectedAddedMessage(for: .coffee)
        )
        
        XCTAssertEqual(
            hapticService.successCallCount,
            1
        )
    }
    
    func testAddWater_syncsAddedWaterWithAppleHealth() async {
        // Arrange
        let storageService = TestWaterStorageService()
        let healthSyncService = TestHealthSyncService()
        
        let sut = makeSUT(
            storageService: storageService,
            healthSyncService: healthSyncService
        )
        
        // Act
        sut.addWater(
            200,
            drinkType: .water
        )
        
        await Task.yield()
        
        // Assert
        XCTAssertEqual(
            healthSyncService.syncedAddedWaterCount,
            1
        )
        
        XCTAssertEqual(
            healthSyncService.lastAddedAmount,
            200
        )
        
        XCTAssertEqual(
            healthSyncService.lastAddedEntryID,
            sut.hydrationState.entries.first?.id
        )
    }
    
    // MARK: - Undo Add
    
    func testUndoLastAction_afterAddingEntry_removesEntry() {
        // Arrange
        let storageService = TestWaterStorageService()
        let hapticService = TestHapticService()
        let sut = makeSUT(
            storageService: storageService,
            hapticService: hapticService
        )
        
        sut.addWater(
            200,
            drinkType: .water
        )
        
        // Act
        sut.undoLastAction()
        
        // Assert
        XCTAssertTrue(
            sut.hydrationState.entries.isEmpty
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            ""
        )
        
        XCTAssertEqual(
            hapticService.warningCallCount,
            1
        )
    }
    
    func testUndoLastAction_afterAddingEntry_syncsDeletedWaterWithAppleHealth() async {
        // Arrange
        let storageService = TestWaterStorageService()
        let healthSyncService = TestHealthSyncService()
        
        let sut = makeSUT(
            storageService: storageService,
            healthSyncService: healthSyncService
        )
        
        sut.addWater(
            200,
            drinkType: .water
        )
        
        let addedEntryID = sut.hydrationState.entries.first?.id
        
        await Task.yield()
        
        // Act
        sut.undoLastAction()
        
        await Task.yield()
        
        // Assert
        XCTAssertEqual(
            healthSyncService.syncedDeletedWaterCount,
            1
        )
        
        XCTAssertEqual(
            healthSyncService.lastDeletedEntryID,
            addedEntryID
        )
    }
    
    // MARK: - Delete
    
    func testDeleteEntry_deletesEntryAndCreatesUndoMessage() {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 500,
            date: Date(),
            drinkType: .juice
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let hapticService = TestHapticService()
        
        let sut = makeSUT(
            storageService: storageService,
            hapticService: hapticService
        )
        
        sut.loadEntries()
        
        // Act
        sut.deleteEntry(entry)
        
        // Assert
        XCTAssertTrue(
            sut.hydrationState.entries.isEmpty
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            expectedDeletedMessage(for: .juice)
        )
        
        XCTAssertEqual(
            hapticService.lightImpactCallCount,
            1
        )
    }
    
    func testDeleteEntry_syncsDeletedWaterWithAppleHealth() async {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 500,
            date: Date(),
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
        
        sut.loadEntries()
        
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
            amount: 300,
            date: Date(),
            drinkType: .tea
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let hapticService = TestHapticService()
        
        let sut = makeSUT(
            storageService: storageService,
            hapticService: hapticService
        )
        
        sut.loadEntries()
        sut.deleteEntry(entry)
        
        // Act
        sut.undoLastAction()
        
        // Assert
        XCTAssertEqual(
            sut.hydrationState.entries.count,
            1
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.id,
            entry.id
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.amount,
            300
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.drinkType,
            .tea
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            ""
        )
        
        XCTAssertEqual(
            hapticService.warningCallCount,
            1
        )
    }
    
    func testUndoLastAction_afterDeletingEntry_syncsAddedWaterWithAppleHealth() async {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 300,
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
        
        sut.loadEntries()
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
    
    // MARK: - Loading
    
    func testLoadEntries_loadsEntriesForToday() {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 250,
            date: Date(),
            drinkType: .water
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let sut = makeSUT(
            storageService: storageService
        )
        
        // Act
        sut.loadEntries()
        
        // Assert
        XCTAssertEqual(
            sut.hydrationState.entries.count,
            1
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.id,
            entry.id
        )
    }
    
    // MARK: - Error Reporting
    
    func testLoadEntries_whenStorageFails_reportsError() {
        // Arrange
        let storageService = TestWaterStorageService()
        let errorReporter = TestErrorReporter()
        
        storageService.fetchEntriesError = TestStorageError.requestedFailure
        
        let sut = makeSUT(
            storageService: storageService,
            hapticService: TestHapticService(),
            errorReporter: errorReporter
        )
        
        // Act
        sut.loadEntries()
        
        // Assert
        XCTAssertEqual(
            errorReporter.reports.count,
            1
        )
        
        XCTAssertEqual(
            errorReporter.reports.first?.context,
            "Failed to fetch water entries"
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        storageService: TestWaterStorageService
    ) -> HomeViewModel {
        HomeViewModel(
            storageService: storageService,
            streakDayService: TestHydrationStreakDayService(),
            hapticService: TestHapticService(),
            errorReporter: TestErrorReporter(),
            widgetSnapshotService: TestWidgetSnapshotService(),
            healthSyncService: TestHealthSyncService()
        )
    }
    
    private func makeSUT(
        storageService: TestWaterStorageService,
        hapticService: TestHapticService
    ) -> HomeViewModel {
        HomeViewModel(
            storageService: storageService,
            streakDayService: TestHydrationStreakDayService(),
            hapticService: hapticService,
            errorReporter: TestErrorReporter(),
            widgetSnapshotService: TestWidgetSnapshotService(),
            healthSyncService: TestHealthSyncService()
        )
    }
    
    private func makeSUT(
        storageService: TestWaterStorageService,
        hapticService: TestHapticService,
        errorReporter: TestErrorReporter
    ) -> HomeViewModel {
        HomeViewModel(
            storageService: storageService,
            streakDayService: TestHydrationStreakDayService(),
            hapticService: hapticService,
            errorReporter: errorReporter,
            widgetSnapshotService: TestWidgetSnapshotService(),
            healthSyncService: TestHealthSyncService()
        )
    }
    
    private func makeSUT(
        storageService: TestWaterStorageService,
        healthSyncService: TestHealthSyncService
    ) -> HomeViewModel {
        HomeViewModel(
            storageService: storageService,
            streakDayService: TestHydrationStreakDayService(),
            hapticService: TestHapticService(),
            errorReporter: TestErrorReporter(),
            widgetSnapshotService: TestWidgetSnapshotService(),
            healthSyncService: healthSyncService
        )
    }
    
    private final class TestHydrationStreakDayService: HydrationStreakDayTracking {
        func markTodayIfEntryIsForToday(
            entryDate: Date
        ) throws {}
        
        func fetchStreakDays() throws -> Set<Date> {
            []
        }
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
