//
//  BackupFileDocument.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct BackupFileDocument: FileDocument {

    // MARK: - Properties

    static let readableContentTypes: [UTType] = [.json]

    let data: Data

    // MARK: - Initializers

    init(
        data: Data
    ) {
        self.data = data
    }

    init(
        configuration: ReadConfiguration
    ) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        self.data = data
    }

    // MARK: - FileDocument

    func fileWrapper(
        configuration: WriteConfiguration
    ) throws -> FileWrapper {
        FileWrapper(
            regularFileWithContents: data
        )
    }
}
