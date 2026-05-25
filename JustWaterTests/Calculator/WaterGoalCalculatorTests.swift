//
//  WaterGoalCalculatorTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
@testable import JustWater

final class WaterGoalCalculatorTests: XCTestCase {
    
    // MARK: - Base Calculation
    
    func testRecommendedGoal_forFemaleWithLowActivity_calculatesBaseGoal() {
        // Arrange / Act
        let result = WaterGoalCalculator.recommendedGoal(
            weight: 70,
            gender: .female,
            activityLevel: .low
        )
        
        // Assert
        // 70 * 32 = 2240
        // rounded to nearest 50 = 2250
        XCTAssertEqual(
            result,
            2250
        )
    }
    
    func testRecommendedGoal_forMaleWithLowActivity_addsGenderAdjustment() {
        // Arrange / Act
        let result = WaterGoalCalculator.recommendedGoal(
            weight: 70,
            gender: .male,
            activityLevel: .low
        )
        
        // Assert
        // 70 * 32 = 2240
        // + 150 for male = 2390
        // rounded to nearest 50 = 2400
        XCTAssertEqual(
            result,
            2400
        )
    }
    
    // MARK: - Activity Level
    
    func testRecommendedGoal_forModerateActivity_appliesModerateMultiplier() {
        // Arrange / Act
        let result = WaterGoalCalculator.recommendedGoal(
            weight: 70,
            gender: .female,
            activityLevel: .moderate
        )
        
        // Assert
        // 70 * 32 = 2240
        // 2240 * 1.1 = 2464
        // rounded to nearest 50 = 2450
        XCTAssertEqual(
            result,
            2450
        )
    }
    
    func testRecommendedGoal_forHighActivity_appliesHighMultiplier() {
        // Arrange / Act
        let result = WaterGoalCalculator.recommendedGoal(
            weight: 80,
            gender: .female,
            activityLevel: .high
        )
        
        // Assert
        // 80 * 32 = 2560
        // 2560 * 1.2 = 3072
        // rounded to nearest 50 = 3050
        XCTAssertEqual(
            result,
            3050
        )
    }
    
    // MARK: - Rounding
    
    func testRecommendedGoal_roundsToNearest50() {
        // Arrange / Act
        let result = WaterGoalCalculator.recommendedGoal(
            weight: 71,
            gender: .female,
            activityLevel: .moderate
        )
        
        // Assert
        // 71 * 32 = 2272
        // 2272 * 1.1 = 2499.2
        // rounded to nearest 50 = 2500
        XCTAssertEqual(
            result,
            2500
        )
    }
    
    // MARK: - Limits
    
    func testRecommendedGoal_whenCalculatedGoalIsBelowMinimum_returnsMinimumGoal() {
        // Arrange / Act
        let result = WaterGoalCalculator.recommendedGoal(
            weight: 20,
            gender: .female,
            activityLevel: .low
        )
        
        // Assert
        // 20 * 32 = 640
        // rounded = 650
        // clamped to minimum = 1500
        XCTAssertEqual(
            result,
            1500
        )
    }
    
    func testRecommendedGoal_whenCalculatedGoalExceedsMaximum_returnsMaximumGoal() {
        // Arrange / Act
        let result = WaterGoalCalculator.recommendedGoal(
            weight: 250,
            gender: .male,
            activityLevel: .high
        )
        
        // Assert
        // 250 * 32 = 8000
        // 8000 * 1.2 = 9600
        // + 150 = 9750
        // clamped to maximum = 5000
        XCTAssertEqual(
            result,
            5000
        )
    }
}
