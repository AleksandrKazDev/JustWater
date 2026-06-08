//
//  MeasurementUnitFormatterTests.swift
//  JustWaterTests
//
//  Created by сонный on 09.06.2026.
//

import XCTest
@testable import JustWater

final class MeasurementUnitFormatterTests: XCTestCase {
    
    func testString_whenUnitIsMilliliters_formatsWithoutFractionDigits() {
        let formatter = MeasurementUnitFormatter(
            locale: Locale(identifier: "en_US")
        )
        
        XCTAssertEqual(
            formatter.string(
                fromMilliliters: 250,
                unit: .milliliters
            ),
            "250 ml"
        )
    }
    
    func testString_whenUnitIsMilliliters_formatsLargeNumberWithGrouping() {
        let formatter = MeasurementUnitFormatter(
            locale: Locale(identifier: "en_US")
        )
        
        XCTAssertEqual(
            formatter.string(
                fromMilliliters: 2000,
                unit: .milliliters
            ),
            "2,000 ml"
        )
    }
    
    func testString_whenUnitIsFluidOunces_formatsWithOneFractionDigitWhenNeeded() {
        let formatter = MeasurementUnitFormatter(
            locale: Locale(identifier: "en_US")
        )
        
        XCTAssertEqual(
            formatter.string(
                fromMilliliters: 250,
                unit: .fluidOunces
            ),
            "8.5 fl oz"
        )
    }
    
    func testString_whenFluidOuncesValueIsWholeNumber_omitsFractionDigits() {
        let formatter = MeasurementUnitFormatter(
            locale: Locale(identifier: "en_US")
        )
        
        XCTAssertEqual(
            formatter.string(
                fromMilliliters: 237,
                unit: .fluidOunces
            ),
            "8 fl oz"
        )
    }
    
    func testInputString_whenUnitIsFluidOunces_returnsValueWithoutUnit() {
        let formatter = MeasurementUnitFormatter(
            locale: Locale(identifier: "en_US")
        )
        
        XCTAssertEqual(
            formatter.inputString(
                fromMilliliters: 250,
                unit: .fluidOunces
            ),
            "8.5"
        )
    }
}
