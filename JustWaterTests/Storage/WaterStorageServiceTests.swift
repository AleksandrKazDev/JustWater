//
//  WaterStorageServiceTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
import SwiftData
@testable import JustWater

@MainActor
final class WaterStorageServiceTests: XCTestCase {
    
    // MARK: - Properties

        private var modelContainer: ModelContainer!
    
    // MARK: - Lifecycle
    
        override func tearDown() async throws {
            modelContainer = nil
            try await super.tearDown()
        }
    
    // MARK: - Saving
    
    func testSaveEntry_savesEntryWithProvidedValues() throws {
        // Arrange
        let sut = try makeSUT()
        let date = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 10
        )
        
        // Act
        let savedEntry = try sut.saveEntry(
            amount: 350,
            date: date,
            drinkType: .coffee
        )
        
        let entries = try sut.fetchEntries()
        
        // Assert
        XCTAssertEqual(
            entries.count,
            1
        )
        
        XCTAssertEqual(
            entries.first?.id,
            savedEntry.id
        )
        
        XCTAssertEqual(
            entries.first?.amount,
            350
        )
        
        XCTAssertEqual(
            entries.first?.date,
            date
        )
        
        XCTAssertEqual(
            entries.first?.drinkType,
            .coffee
        )
    }
    
    func testSaveEntry_withoutDrinkType_savesWaterByDefault() throws {
        // Arrange
        let sut = try makeSUT()
        let date = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        // Act
        try sut.saveEntry(
            amount: 200,
            date: date,
            drinkType: .water
        )
        
        let entries = try sut.fetchEntries()
        
        // Assert
        XCTAssertEqual(
            entries.first?.drinkType,
            .water
        )
    }
    
    // MARK: - Fetching
    
    func testFetchEntries_returnsEntriesSortedByDateDescending() throws {
        // Arrange
        let sut = try makeSUT()
        
        let olderDate = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 9
        )
        
        let newerDate = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 12
        )
        
        try sut.saveEntry(
            amount: 100,
            date: olderDate,
            drinkType: .water
        )
        
        try sut.saveEntry(
            amount: 200,
            date: newerDate,
            drinkType: .tea
        )
        
        // Act
        let entries = try sut.fetchEntries()
        
        // Assert
        XCTAssertEqual(
            entries.map(\.amount),
            [200, 100]
        )
        
        XCTAssertEqual(
            entries.map(\.drinkType),
            [.tea, .water]
        )
    }
    
    func testFetchEntriesForDate_returnsOnlyEntriesFromSelectedDay() throws {
        // Arrange
        let sut = try makeSUT()
        
        let selectedDate = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 10
        )
        
        let sameDayDate = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 22
        )
        
        let anotherDayDate = makeDate(
            year: 2026,
            month: 5,
            day: 26,
            hour: 10
        )
        
        try sut.saveEntry(
            amount: 300,
            date: selectedDate,
            drinkType: .water
        )
        
        try sut.saveEntry(
            amount: 500,
            date: sameDayDate,
            drinkType: .coffee
        )
        
        try sut.saveEntry(
            amount: 700,
            date: anotherDayDate,
            drinkType: .juice
        )
        
        // Act
        let entries = try sut.fetchEntries(
            for: selectedDate
        )
        
        // Assert
        XCTAssertEqual(
            entries.count,
            2
        )
        
        XCTAssertEqual(
            entries.map(\.amount),
            [500, 300]
        )
    }
    
    func testFetchEntriesFromTo_returnsOnlyEntriesInsideRange() throws {
        // Arrange
        let sut = try makeSUT()
        
        let startDate = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 0
        )
        
        let insideDate = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 12
        )
        
        let endDate = makeDate(
            year: 2026,
            month: 5,
            day: 26,
            hour: 0
        )
        
        let outsideDate = makeDate(
            year: 2026,
            month: 5,
            day: 26,
            hour: 12
        )
        
        try sut.saveEntry(
            amount: 400,
            date: insideDate,
            drinkType: .water
        )
        
        try sut.saveEntry(
            amount: 800,
            date: outsideDate,
            drinkType: .coffee
        )
        
        // Act
        let entries = try sut.fetchEntries(
            from: startDate,
            to: endDate
        )
        
        // Assert
        XCTAssertEqual(
            entries.count,
            1
        )
        
        XCTAssertEqual(
            entries.first?.amount,
            400
        )
    }
    
    // MARK: - Updating
    
    func testUpdateEntry_updatesExistingEntry() throws {
        // Arrange
        let sut = try makeSUT()
        
        let originalDate = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 10
        )
        
        let updatedDate = makeDate(
            year: 2026,
            month: 5,
            day: 26,
            hour: 11
        )
        
        let savedEntry = try sut.saveEntry(
            amount: 250,
            date: originalDate,
            drinkType: .water
        )
        
        // Act
        try sut.updateEntry(
            id: savedEntry.id,
            amount: 900,
            date: updatedDate,
            drinkType: .coffee
        )
        
        let entries = try sut.fetchEntries()
        
        // Assert
        XCTAssertEqual(
            entries.count,
            1
        )
        
        XCTAssertEqual(
            entries.first?.id,
            savedEntry.id
        )
        
        XCTAssertEqual(
            entries.first?.amount,
            900
        )
        
        XCTAssertEqual(
            entries.first?.date,
            updatedDate
        )
        
        XCTAssertEqual(
            entries.first?.drinkType,
            .coffee
        )
    }
    
    // MARK: - Deleting
    
    func testDeleteEntry_removesExistingEntry() throws {
        // Arrange
        let sut = try makeSUT()
        
        let savedEntry = try sut.saveEntry(
            amount: 250,
            date: Date(),
            drinkType: .water
        )
        
        // Act
        try sut.deleteEntry(
            id: savedEntry.id
        )
        
        let entries = try sut.fetchEntries()
        
        // Assert
        XCTAssertTrue(
            entries.isEmpty
        )
    }
    
    func testDeleteEntry_whenEntryDoesNotExist_doesNotThrow() throws {
        // Arrange
        let sut = try makeSUT()
        
        // Act / Assert
        XCTAssertNoThrow(
            try sut.deleteEntry(id: UUID())
        )
    }
    
    // MARK: - Restoring
    
    func testRestoreEntry_restoresSnapshotValues() throws {
        // Arrange
        let sut = try makeSUT()
        
        let originalEntry = WaterEntry(
            id: UUID(),
            amount: 650,
            date: makeDate(year: 2026, month: 5, day: 25),
            drinkType: .tea
        )
        
        let snapshot = WaterEntrySnapshot(
            entry: originalEntry
        )
        
        // Act
        let restoredEntry = try sut.restoreEntry(
            from: snapshot
        )
        
        let entries = try sut.fetchEntries()
        
        // Assert
        XCTAssertEqual(
            restoredEntry,
            originalEntry
        )
        
        XCTAssertEqual(
            entries.count,
            1
        )
        
        XCTAssertEqual(
            entries.first,
            originalEntry
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT() throws -> WaterStorageService {
        let schema = Schema([
            WaterEntryEntity.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        modelContainer = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        
        return WaterStorageService(
            context: modelContainer.mainContext
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
