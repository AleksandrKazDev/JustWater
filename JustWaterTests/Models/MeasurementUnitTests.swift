//
//  MeasurementUnitTests.swift
//  JustWaterTests
//
//  Created by сонный on 09.06.2026.
//

import XCTest
@testable import JustWater

final class MeasurementUnitTests: XCTestCase {
    
    func testDefaultUnit_whenRegionIsUS_returnsFluidOunces() {
        XCTAssertEqual(
            MeasurementUnit.defaultUnit(
                for: Locale(identifier: "en_US")
            ),
            .fluidOunces
        )
    }
    
    func testDefaultUnit_whenRegionIsNotUS_returnsMilliliters() {
        XCTAssertEqual(
            MeasurementUnit.defaultUnit(
                for: Locale(identifier: "ru_RU")
            ),
            .milliliters
        )
        
        XCTAssertEqual(
            MeasurementUnit.defaultUnit(
                for: Locale(identifier: "kk_KZ")
            ),
            .milliliters
        )
        
        XCTAssertEqual(
            MeasurementUnit.defaultUnit(
                for: Locale(identifier: "en_GB")
            ),
            .milliliters
        )
    }
    
    func testToggled_whenUnitIsMilliliters_returnsFluidOunces() {
        XCTAssertEqual(
            MeasurementUnit.milliliters.toggled,
            .fluidOunces
        )
    }
    
    func testToggled_whenUnitIsFluidOunces_returnsMilliliters() {
        XCTAssertEqual(
            MeasurementUnit.fluidOunces.toggled,
            .milliliters
        )
    }
}
