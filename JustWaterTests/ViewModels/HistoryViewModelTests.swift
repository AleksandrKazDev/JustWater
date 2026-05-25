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
            "Coffee deleted"
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
        let sut = makeSUT(
            storageService: storageService
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
    
    // MARK: - Helpers
    
    private func makeSUT(
        storageService: TestWaterStorageService,
        goalStorageService: TestWaterGoalStorageService? = nil
    ) -> HistoryViewModel {
        HistoryViewModel(
            storageService: storageService,
            goalStorageService: goalStorageService ?? TestWaterGoalStorageService()
        )
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
}
