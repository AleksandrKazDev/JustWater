//
//  HistoryViewModelTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
@testable import JustWater

@MainActor
final class HistoryViewModelTests: XCTestCase {
    
    // MARK: - Delete
    
    func testDeleteEntry_deletesEntryAndCreatesUndoMessage() {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 250,
            date: Date(),
            drinkType: .coffee
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let sut = HistoryViewModel(
            storageService: storageService
        )
        
        // Act
        sut.deleteEntry(entry)
        
        // Assert
        XCTAssertTrue(
            storageService.entries.isEmpty
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            "Coffee deleted"
        )
    }
    
    // MARK: - Undo Delete
    
    func testUndoLastAction_afterDeletingEntry_restoresEntry() {
        // Arrange
        let entry = WaterEntry(
            id: UUID(),
            amount: 400,
            date: Date(),
            drinkType: .tea
        )
        
        let storageService = TestWaterStorageService(
            entries: [entry]
        )
        
        let sut = HistoryViewModel(
            storageService: storageService
        )
        
        sut.deleteEntry(entry)
        
        // Act
        sut.undoLastAction()
        
        // Assert
        XCTAssertEqual(
            storageService.entries.count,
            1
        )
        
        XCTAssertEqual(
            storageService.entries.first?.id,
            entry.id
        )
        
        XCTAssertEqual(
            storageService.entries.first?.amount,
            400
        )
        
        XCTAssertEqual(
            storageService.entries.first?.drinkType,
            .tea
        )
        
        XCTAssertEqual(
            sut.undoBannerMessage,
            ""
        )
    }
}
