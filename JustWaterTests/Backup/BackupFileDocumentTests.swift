//
//  BackupFileDocumentTests.swift
//  JustWaterTests
//
//  Created by сонный on 22.07.2026.
//

import Foundation
import UniformTypeIdentifiers
import XCTest
@testable import JustWater

final class BackupFileDocumentTests: XCTestCase {

    func testReadableContentTypes_containsJSON() {
        XCTAssertEqual(
            BackupFileDocument.readableContentTypes,
            [.json]
        )
    }

    func testDocument_preservesBackupData() {
        let data = Data(
            "{\"schemaVersion\":1}".utf8
        )
        let document = BackupFileDocument(
            data: data
        )

        XCTAssertEqual(
            document.data,
            data
        )
    }
}
