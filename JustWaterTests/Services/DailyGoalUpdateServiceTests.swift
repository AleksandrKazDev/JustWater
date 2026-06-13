//
//  DailyGoalUpdateServiceTests.swift
//  JustWaterTests
//
//  Created by сонный on 26.05.2026.
//

import XCTest
@testable import JustWater

@MainActor
final class DailyGoalUpdateServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        AppSettingsStorageTestSupport.setUpIsolatedDefaults()
    }
    
    override func tearDown() {
        AppSettingsStorageTestSupport.tearDownIsolatedDefaults()
        super.tearDown()
    }
    
    func testUpdateDailyGoal_updatesGoalStorageForToday() throws {
        // Arrange
        let goalStorageService = TestWaterGoalStorageService(
            fallbackGoal: 2000
        )
        
        let sut = DailyGoalUpdateService(
            goalStorageService: goalStorageService
        )
        
        // Act
        try sut.updateDailyGoal(3000)
        
        // Assert
        let todayGoal = try goalStorageService.goal(
            for: Date.now
        )
        
        XCTAssertEqual(
            todayGoal,
            3000
        )
    }
    
    func testUpdateDailyGoal_updatesAppSettingsStorageDailyGoal() throws {
        // Arrange
        let goalStorageService = TestWaterGoalStorageService(
            fallbackGoal: 2000
        )
        
        let sut = DailyGoalUpdateService(
            goalStorageService: goalStorageService
        )
        
        // Act
        try sut.updateDailyGoal(3200)
        
        // Assert
        XCTAssertEqual(
            AppSettingsStorage.dailyGoal,
            3200
        )
    }
}
