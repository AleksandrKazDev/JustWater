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
            expectedAddedMessage(for: .water)
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
            expectedAddedMessage(for: .coffee)
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
            expectedDeletedMessage(for: .tea)
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
            expectedDeletedMessage(for: .juice)
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
    
    private func expectedAddedMessage(
        for drinkType: DrinkType
    ) -> String {
        String(
            format: String(localized: "undo.added"),
            drinkType.title
        )
    }
    
    private func expectedDeletedMessage(
        for drinkType: DrinkType
    ) -> String {
        String(
            format: String(localized: "undo.deleted"),
            drinkType.title
        )
    }
}
