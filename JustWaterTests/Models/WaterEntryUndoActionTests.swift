//
//  WaterEntryUndoActionTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
@testable import JustWater

final class WaterEntryUndoActionTests: XCTestCase {
    
    func testMessage_whenActionIsAdded_returnsWaterAddedMessage() {
        // Arrange
        let snapshot = makeSnapshot(
            drinkType: .water
        )
        
        let sut = WaterEntryUndoAction.added(snapshot)
        
        // Assert
        XCTAssertEqual(
            sut.message,
            "Water added"
        )
    }
    
    func testMessage_whenAddedActionUsesCoffee_returnsCoffeeAddedMessage() {
        // Arrange
        let snapshot = makeSnapshot(
            drinkType: .coffee
        )
        
        let sut = WaterEntryUndoAction.added(snapshot)
        
        // Assert
        XCTAssertEqual(
            sut.message,
            "Coffee added"
        )
    }
    
    func testMessage_whenActionIsDeleted_returnsTeaDeletedMessage() {
        // Arrange
        let snapshot = makeSnapshot(
            drinkType: .tea
        )
        
        let sut = WaterEntryUndoAction.deleted(snapshot)
        
        // Assert
        XCTAssertEqual(
            sut.message,
            "Tea deleted"
        )
    }
    
    func testMessage_whenDeletedActionUsesJuice_returnsJuiceDeletedMessage() {
        // Arrange
        let snapshot = makeSnapshot(
            drinkType: .juice
        )
        
        let sut = WaterEntryUndoAction.deleted(snapshot)
        
        // Assert
        XCTAssertEqual(
            sut.message,
            "Juice deleted"
        )
    }
    
    // MARK: - Helpers
    
    private func makeSnapshot(
        amount: Int = 250,
        date: Date = Date(),
        drinkType: DrinkType
    ) -> WaterEntrySnapshot {
        let entry = WaterEntry(
            id: UUID(),
            amount: amount,
            date: date,
            drinkType: drinkType
        )
        
        return WaterEntrySnapshot(
            entry: entry
        )
    }
}
