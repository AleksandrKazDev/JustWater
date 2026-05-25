//
//  WaterEntrySnapshotTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
@testable import JustWater

final class WaterEntrySnapshotTests: XCTestCase {
    
    func testInit_preservesEntryValues() {
        // Arrange
        let id = UUID()
        let date = Date()
        
        let entry = WaterEntry(
            id: id,
            amount: 350,
            date: date,
            drinkType: .coffee
        )
        
        // Act
        let sut = WaterEntrySnapshot(
            entry: entry
        )
        
        // Assert
        XCTAssertEqual(
            sut.id,
            id
        )
        
        XCTAssertEqual(
            sut.amount,
            350
        )
        
        XCTAssertEqual(
            sut.date,
            date
        )
        
        XCTAssertEqual(
            sut.drinkType,
            .coffee
        )
    }
    
    func testEntry_returnsWaterEntryWithSnapshotValues() {
        // Arrange
        let id = UUID()
        let date = Date()
        
        let originalEntry = WaterEntry(
            id: id,
            amount: 500,
            date: date,
            drinkType: .tea
        )
        
        let sut = WaterEntrySnapshot(
            entry: originalEntry
        )
        
        // Act
        let restoredEntry = sut.entry
        
        // Assert
        XCTAssertEqual(
            restoredEntry.id,
            id
        )
        
        XCTAssertEqual(
            restoredEntry.amount,
            500
        )
        
        XCTAssertEqual(
            restoredEntry.date,
            date
        )
        
        XCTAssertEqual(
            restoredEntry.drinkType,
            .tea
        )
    }
}
