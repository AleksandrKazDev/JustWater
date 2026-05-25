//
//  HydrationStateTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
@testable import JustWater

final class HydrationStateTests: XCTestCase {
    
    // MARK: - Consumed Water
    
    func testConsumedWater_whenEntriesAreEmpty_returnsZero() {
        // Arrange
        let sut = HydrationState(
            dailyGoal: 2500,
            entries: []
        )
        
        // Assert
        XCTAssertEqual(
            sut.consumedWater,
            0
        )
    }
    
    func testConsumedWater_whenEntriesExist_returnsSumOfAmounts() {
        // Arrange
        let sut = HydrationState(
            dailyGoal: 2500,
            entries: [
                makeEntry(amount: 200),
                makeEntry(amount: 300),
                makeEntry(amount: 500)
            ]
        )
        
        // Assert
        XCTAssertEqual(
            sut.consumedWater,
            1000
        )
    }
    
    // MARK: - Completion Rate
    
    func testCompletionRate_whenDailyGoalIsPositive_returnsConsumedWaterDividedByDailyGoal() {
        // Arrange
        let sut = HydrationState(
            dailyGoal: 2000,
            entries: [
                makeEntry(amount: 500),
                makeEntry(amount: 500)
            ]
        )
        
        // Assert
        XCTAssertEqual(
            sut.completionRate,
            0.5,
            accuracy: 0.0001
        )
    }
    
    func testCompletionRate_whenDailyGoalIsZero_returnsZero() {
        // Arrange
        let sut = HydrationState(
            dailyGoal: 0,
            entries: [
                makeEntry(amount: 500)
            ]
        )
        
        // Assert
        XCTAssertEqual(
            sut.completionRate,
            0
        )
    }
    
    func testCompletionRate_whenConsumedWaterExceedsGoal_canBeGreaterThanOne() {
        // Arrange
        let sut = HydrationState(
            dailyGoal: 2000,
            entries: [
                makeEntry(amount: 1500),
                makeEntry(amount: 1200)
            ]
        )
        
        // Assert
        XCTAssertEqual(
            sut.completionRate,
            1.35,
            accuracy: 0.0001
        )
    }
    
    // MARK: - Visual Progress
    
    func testVisualProgress_whenCompletionRateIsBelowOne_matchesCompletionRate() {
        // Arrange
        let sut = HydrationState(
            dailyGoal: 2000,
            entries: [
                makeEntry(amount: 800)
            ]
        )
        
        // Assert
        XCTAssertEqual(
            sut.visualProgress,
            0.4,
            accuracy: 0.0001
        )
    }
    
    func testVisualProgress_whenCompletionRateExceedsOne_isCappedAtOne() {
        // Arrange
        let sut = HydrationState(
            dailyGoal: 2000,
            entries: [
                makeEntry(amount: 3000)
            ]
        )
        
        // Assert
        XCTAssertEqual(
            sut.visualProgress,
            1.0,
            accuracy: 0.0001
        )
    }
    
    // MARK: - Remaining Water
    
    func testRemainingWater_whenConsumedWaterIsBelowGoal_returnsDifference() {
        // Arrange
        let sut = HydrationState(
            dailyGoal: 2500,
            entries: [
                makeEntry(amount: 700),
                makeEntry(amount: 300)
            ]
        )
        
        // Assert
        XCTAssertEqual(
            sut.remainingWater,
            1500
        )
    }
    
    func testRemainingWater_whenConsumedWaterExceedsGoal_returnsZero() {
        // Arrange
        let sut = HydrationState(
            dailyGoal: 2000,
            entries: [
                makeEntry(amount: 2500)
            ]
        )
        
        // Assert
        XCTAssertEqual(
            sut.remainingWater,
            0
        )
    }
    
    // MARK: - Drink Types
    
    func testConsumedWater_withDifferentDrinkTypes_countsAllEntries() {
        // Arrange
        let sut = HydrationState(
            dailyGoal: 2500,
            entries: [
                makeEntry(amount: 200, drinkType: .water),
                makeEntry(amount: 150, drinkType: .coffee),
                makeEntry(amount: 300, drinkType: .tea)
            ]
        )
        
        // Assert
        XCTAssertEqual(
            sut.consumedWater,
            650
        )
    }
    
    // MARK: - Helpers
    
    private func makeEntry(
        id: UUID = UUID(),
        amount: Int,
        date: Date = Date(),
        drinkType: DrinkType = .water
    ) -> WaterEntry {
        WaterEntry(
            id: id,
            amount: amount,
            date: date,
            drinkType: drinkType
        )
    }
}
