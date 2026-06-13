//
//  WaterGoalStorageServiceTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
import SwiftData
@testable import JustWater

@MainActor
final class WaterGoalStorageServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private var modelContainer: ModelContainer!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        AppSettingsStorageTestSupport.setUpIsolatedDefaults()
    }
    
    override func tearDown() async throws {
        AppSettingsStorageTestSupport.tearDownIsolatedDefaults()
        modelContainer = nil
        try await super.tearDown()
    }
    
    // MARK: - Current Goal
    
    func testCurrentGoal_whenNoRecordsExist_returnsFallbackGoalAndCreatesInitialRecord() throws {
        // Arrange
        let sut = try makeSUT()
        
        // Act
        let goal = try sut.currentGoal()
        
        // Assert
        XCTAssertEqual(
            goal,
            AppSettingsStorage.dailyGoal
        )
    }
    
    func testCurrentGoal_afterGoalUpdate_returnsLatestGoal() throws {
        // Arrange
        let sut = try makeSUT()
        
        let firstDate = makeDate(
            year: 2026,
            month: 5,
            day: 20
        )
        
        let secondDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        try sut.updateGoal(
            2000,
            effectiveDate: firstDate
        )
        
        try sut.updateGoal(
            3000,
            effectiveDate: secondDate
        )
        
        // Act
        let goal = try sut.currentGoal()
        
        // Assert
        XCTAssertEqual(
            goal,
            3000
        )
    }
    
    // MARK: - Goal For Date
    
    func testGoalForDate_returnsGoalEffectiveForThatDate() throws {
        // Arrange
        let sut = try makeSUT()
        
        let oldGoalDate = makeDate(
            year: 2026,
            month: 5,
            day: 20
        )
        
        let newGoalDate = makeDate(
            year: 2026,
            month: 5,
            day: 26
        )
        
        try sut.updateGoal(
            2000,
            effectiveDate: oldGoalDate
        )
        
        try sut.updateGoal(
            3000,
            effectiveDate: newGoalDate
        )
        
        let dateBeforeChange = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let dateAfterChange = makeDate(
            year: 2026,
            month: 5,
            day: 26
        )
        
        // Act
        let oldGoal = try sut.goal(
            for: dateBeforeChange
        )
        
        let newGoal = try sut.goal(
            for: dateAfterChange
        )
        
        // Assert
        XCTAssertEqual(
            oldGoal,
            2000
        )
        
        XCTAssertEqual(
            newGoal,
            3000
        )
    }
    
    func testUpdateGoal_normalizesEffectiveDateToStartOfDay() throws {
        // Arrange
        let sut = try makeSUT()
        
        let effectiveDate = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 22,
            minute: 30
        )
        
        let sameDayMorning = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 8
        )
        
        // Act
        try sut.updateGoal(
            2800,
            effectiveDate: effectiveDate
        )
        
        let goal = try sut.goal(
            for: sameDayMorning
        )
        
        // Assert
        XCTAssertEqual(
            goal,
            2800
        )
    }
    
    func testUpdateGoal_whenRecordForSameDayExists_updatesExistingGoal() throws {
        // Arrange
        let sut = try makeSUT()
        
        let morning = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 8
        )
        
        let evening = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 22
        )
        
        try sut.updateGoal(
            2000,
            effectiveDate: morning
        )
        
        try sut.updateGoal(
            3000,
            effectiveDate: evening
        )
        
        // Act
        let goal = try sut.goal(
            for: morning
        )
        
        // Assert
        XCTAssertEqual(
            goal,
            3000
        )
    }
    
    // MARK: - Goals By Day
    
    func testGoalsByDay_returnsGoalForEachDayInRange() throws {
        // Arrange
        let sut = try makeSUT()
        
        let oldGoalDate = makeDate(
            year: 2026,
            month: 5,
            day: 20
        )
        
        let newGoalDate = makeDate(
            year: 2026,
            month: 5,
            day: 26
        )
        
        try sut.updateGoal(
            2000,
            effectiveDate: oldGoalDate
        )
        
        try sut.updateGoal(
            3000,
            effectiveDate: newGoalDate
        )
        
        let startDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let endDate = makeDate(
            year: 2026,
            month: 5,
            day: 28
        )
        
        // Act
        let goalsByDay = try sut.goalsByDay(
            from: startDate,
            to: endDate
        )
        
        // Assert
        XCTAssertEqual(
            goalsByDay.count,
            3
        )
        
        XCTAssertEqual(
            goalsByDay[startOfDay(year: 2026, month: 5, day: 25)],
            2000
        )
        
        XCTAssertEqual(
            goalsByDay[startOfDay(year: 2026, month: 5, day: 26)],
            3000
        )
        
        XCTAssertEqual(
            goalsByDay[startOfDay(year: 2026, month: 5, day: 27)],
            3000
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT() throws -> WaterGoalStorageService {
        let schema = Schema([
            WaterEntryEntity.self,
            WaterGoalEntity.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        modelContainer = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        
        return WaterGoalStorageService(
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
    
    private func startOfDay(
        year: Int,
        month: Int,
        day: Int
    ) -> Date {
        Calendar.current.startOfDay(
            for: makeDate(
                year: year,
                month: month,
                day: day
            )
        )
    }
}
