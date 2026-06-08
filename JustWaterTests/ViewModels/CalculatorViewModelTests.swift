//
//  CalculatorViewModelTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
@testable import JustWater

final class CalculatorViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        AppSettingsStorage.measurementUnit = .milliliters
    }
    
    override func tearDown() {
        AppSettingsStorage.measurementUnit = .milliliters
        super.tearDown()
    }
    
    // MARK: - Weight Input
    
    func testUpdateWeightText_whenValueContainsNonDigits_keepsOnlyDigits() {
        // Arrange
        let sut = CalculatorViewModel()
        
        // Act
        sut.updateWeightText("7a0 kg")
        
        // Assert
        XCTAssertEqual(
            sut.weightText,
            "70"
        )
    }
    
    func testUpdateWeightText_whenValueExceedsMaximumWeight_capsAtMaximumWeight() {
        // Arrange
        let sut = CalculatorViewModel()
        
        // Act
        sut.updateWeightText("999")
        
        // Assert
        XCTAssertEqual(
            sut.weightText,
            "250"
        )
    }
    
    func testUpdateWeightText_resetsRecommendedGoal() {
        // Arrange
        let sut = CalculatorViewModel()
        sut.weightText = "70"
        sut.calculateGoal()
        
        XCTAssertNotNil(
            sut.recommendedGoal
        )
        
        // Act
        sut.updateWeightText("80")
        
        // Assert
        XCTAssertNil(
            sut.recommendedGoal
        )
    }
    
    // MARK: - Calculate Goal
    
    func testCalculateGoal_whenWeightIsEmpty_setsRecommendedGoalToNil() {
        // Arrange
        let sut = CalculatorViewModel()
        sut.weightText = ""
        
        // Act
        sut.calculateGoal()
        
        // Assert
        XCTAssertNil(
            sut.recommendedGoal
        )
    }
    
    func testCalculateGoal_whenWeightIsZero_setsRecommendedGoalToNil() {
        // Arrange
        let sut = CalculatorViewModel()
        sut.weightText = "0"
        
        // Act
        sut.calculateGoal()
        
        // Assert
        XCTAssertNil(
            sut.recommendedGoal
        )
    }
    
    func testCalculateGoal_whenWeightIsValid_setsRecommendedGoal() {
        // Arrange
        let sut = CalculatorViewModel()
        sut.weightText = "70"
        sut.gender = .male
        sut.activityLevel = .moderate
        
        let expectedGoal = WaterGoalCalculator.recommendedGoal(
            weight: 70,
            gender: .male,
            activityLevel: .moderate
        )
        
        // Act
        sut.calculateGoal()
        
        // Assert
        XCTAssertEqual(
            sut.recommendedGoal,
            expectedGoal
        )
    }
    
    // MARK: - Gender
    
    func testSelectGender_updatesGenderAndResetsRecommendedGoal() {
        // Arrange
        let sut = CalculatorViewModel()
        sut.weightText = "70"
        sut.calculateGoal()
        
        XCTAssertNotNil(
            sut.recommendedGoal
        )
        
        // Act
        sut.selectGender(.female)
        
        // Assert
        XCTAssertEqual(
            sut.gender,
            .female
        )
        
        XCTAssertNil(
            sut.recommendedGoal
        )
    }
    
    // MARK: - Activity Level
    
    func testSelectActivityLevel_updatesActivityLevelAndResetsRecommendedGoal() {
        // Arrange
        let sut = CalculatorViewModel()
        sut.weightText = "70"
        sut.calculateGoal()
        
        XCTAssertNotNil(
            sut.recommendedGoal
        )
        
        // Act
        sut.selectActivityLevel(.high)
        
        // Assert
        XCTAssertEqual(
            sut.activityLevel,
            .high
        )
        
        XCTAssertNil(
            sut.recommendedGoal
        )
    }
    
    // MARK: - Custom Goal Input
    
    func testUpdateCustomGoalText_whenValueContainsNonDigits_keepsOnlyDigits() {
        // Arrange
        let sut = CalculatorViewModel()
        
        // Act
        sut.updateCustomGoalText("2_500 ml")
        
        // Assert
        XCTAssertEqual(
            sut.customGoalText,
            "2500"
        )
    }
    
    func testUpdateCustomGoalText_whenValueExceedsMaximumGoal_capsAtMaximumGoal() {
        // Arrange
        let sut = CalculatorViewModel()
        
        // Act
        sut.updateCustomGoalText("50000")
        
        // Assert
        XCTAssertEqual(
            sut.customGoalText,
            "10000"
        )
    }
    
    func testCustomGoal_whenValueIsValid_returnsGoal() {
        // Arrange
        let sut = CalculatorViewModel()
        
        // Act
        sut.updateCustomGoalText("3200")
        
        // Assert
        XCTAssertEqual(
            sut.customGoal,
            3200
        )
    }
    
    func testCustomGoal_whenValueIsEmpty_returnsNil() {
        // Arrange
        let sut = CalculatorViewModel()
        sut.customGoalText = ""
        
        // Assert
        XCTAssertNil(
            sut.customGoal
        )
    }
    
    func testCustomGoal_whenValueIsZero_returnsNil() {
        // Arrange
        let sut = CalculatorViewModel()
        
        // Act
        sut.updateCustomGoalText("0")
        
        // Assert
        XCTAssertNil(
            sut.customGoal
        )
    }
    
    // MARK: - Measurement Unit
    
    func testReloadSettings_whenMeasurementUnitIsFluidOunces_updatesMeasurementUnit() {
        // Arrange
        AppSettingsStorage.measurementUnit = .fluidOunces
        let sut = CalculatorViewModel()
        
        // Act
        sut.reloadSettings()
        
        // Assert
        XCTAssertEqual(
            sut.measurementUnit,
            .fluidOunces
        )
    }
    
    func testUpdateCustomGoalText_whenUnitIsFluidOunces_allowsDecimalSeparatorWithDot() {
        // Arrange
        AppSettingsStorage.measurementUnit = .fluidOunces
        let sut = CalculatorViewModel()
        sut.reloadSettings()
        
        // Act
        sut.updateCustomGoalText("8.5")
        
        // Assert
        XCTAssertEqual(
            sut.customGoalText,
            "8.5"
        )
        
        XCTAssertEqual(
            sut.customGoal,
            251
        )
    }
    
    func testUpdateCustomGoalText_whenUnitIsFluidOunces_allowsDecimalSeparatorWithComma() {
        // Arrange
        AppSettingsStorage.measurementUnit = .fluidOunces
        let sut = CalculatorViewModel()
        sut.reloadSettings()
        
        // Act
        sut.updateCustomGoalText("8,5")
        
        // Assert
        XCTAssertEqual(
            sut.customGoalText,
            "8,5"
        )
        
        XCTAssertEqual(
            sut.customGoal,
            251
        )
    }
    
    func testUpdateCustomGoalText_whenUnitIsFluidOunces_filtersInvalidCharacters() {
        // Arrange
        AppSettingsStorage.measurementUnit = .fluidOunces
        let sut = CalculatorViewModel()
        sut.reloadSettings()
        
        // Act
        sut.updateCustomGoalText("1a2,b5 oz")
        
        // Assert
        XCTAssertEqual(
            sut.customGoalText,
            "12,5"
        )
        
        XCTAssertEqual(
            sut.customGoal,
            370
        )
    }
    
    func testUpdateCustomGoalText_whenUnitIsFluidOunces_capsAtMaximumFluidOunces() {
        // Arrange
        AppSettingsStorage.measurementUnit = .fluidOunces
        let sut = CalculatorViewModel()
        sut.reloadSettings()
        
        // Act
        sut.updateCustomGoalText("999")
        
        // Assert
        XCTAssertEqual(
            sut.customGoalText,
            "338"
        )
    }
}
