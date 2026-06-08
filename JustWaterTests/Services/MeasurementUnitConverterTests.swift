//
//  MeasurementUnitConverterTests.swift
//  JustWaterTests
//
//  Created by сонный on 09.06.2026.
//

import XCTest
@testable import JustWater

final class MeasurementUnitConverterTests: XCTestCase {
    
    func testMillilitersFromMilliliters_returnsRoundedMilliliters() {
        XCTAssertEqual(
            MeasurementUnitConverter.milliliters(
                from: 250,
                unit: .milliliters
            ),
            250
        )
    }
    
    func testMillilitersFromFluidOunces_convertsToMilliliters() {
        XCTAssertEqual(
            MeasurementUnitConverter.milliliters(
                from: 8,
                unit: .fluidOunces
            ),
            237
        )
    }
    
    func testMillilitersFromDecimalFluidOunces_convertsToMilliliters() {
        XCTAssertEqual(
            MeasurementUnitConverter.milliliters(
                from: 8.5,
                unit: .fluidOunces
            ),
            251
        )
    }
    
    func testValueFromMilliliters_whenUnitIsMilliliters_returnsSameValue() {
        XCTAssertEqual(
            MeasurementUnitConverter.value(
                fromMilliliters: 500,
                unit: .milliliters
            ),
            500
        )
    }
    
    func testValueFromMilliliters_whenUnitIsFluidOunces_convertsToFluidOunces() {
        XCTAssertEqual(
            MeasurementUnitConverter.value(
                fromMilliliters: 250,
                unit: .fluidOunces
            ),
            8.45,
            accuracy: 0.01
        )
    }
}
