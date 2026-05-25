//
//  HomeViewModelTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
@testable import JustWater

@MainActor
final class HomeViewModelTests: XCTestCase {
    
    // MARK: - Add
    
    func testAddWater_addsWaterEntryAndCreatesUndoMessage() {
        // Arrange
        let storageService = TestWaterStorageService()
        let sut = HomeViewModel(
            storageService: storageService
        )
        
        // Act
        sut.addWater(
            200,
            drinkType: .water
        )
        
        // Assert
        XCTAssertEqual(
            sut.hydrationState.entries.count,
            1
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.amount,
            200
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.drinkType,
            .water
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            "Water added"
        )
    }
    
    func testAddWater_withCoffee_addsCoffeeEntryAndCreatesUndoMessage() {
        // Arrange
        let storageService = TestWaterStorageService()
        let sut = HomeViewModel(
            storageService: storageService
        )
        
        // Act
        sut.addWater(
            300,
            drinkType: .coffee
        )
        
        // Assert
        XCTAssertEqual(
            sut.hydrationState.entries.count,
            1
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.amount,
            300
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.drinkType,
            .coffee
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            "Coffee added"
        )
    }
    
    // MARK: - Undo Add
    
    func testUndoLastAction_afterAddingEntry_removesEntry() {
        // Arrange
        let storageService = TestWaterStorageService()
        let sut = HomeViewModel(
            storageService: storageService
        )
        
        sut.addWater(
            200,
            drinkType: .water
        )
        
        // Act
        sut.undoLastAction()
        
        // Assert
        XCTAssertTrue(
            sut.hydrationState.entries.isEmpty
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            ""
        )
    }
    
    // MARK: - Delete
    
    func testDeleteEntry_deletesEntryAndCreatesUndoMessage() {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 500,
            date: Date(),
            drinkType: .juice
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let sut = HomeViewModel(
            storageService: storageService
        )
        
        // Act
        sut.deleteEntry(entry)
        
        // Assert
        XCTAssertTrue(
            sut.hydrationState.entries.isEmpty
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            "Juice deleted"
        )
    }
    
    // MARK: - Undo Delete
    
    func testUndoLastAction_afterDeletingEntry_restoresEntry() {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 300,
            date: Date(),
            drinkType: .tea
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let sut = HomeViewModel(
            storageService: storageService
        )
        
        sut.deleteEntry(entry)
        
        // Act
        sut.undoLastAction()
        
        // Assert
        XCTAssertEqual(
            sut.hydrationState.entries.count,
            1
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.id,
            entry.id
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.amount,
            300
        )
        
        XCTAssertEqual(
            sut.hydrationState.entries.first?.drinkType,
            .tea
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            ""
        )
    }
}
