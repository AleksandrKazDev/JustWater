//
//  BackupImportService.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation

protocol BackupImportServicing: Sendable {
    func prepareImport(
        from url: URL
    ) async throws -> PreparedBackupImport
}

actor BackupImportService: BackupImportServicing {

    // MARK: - Properties

    static let defaultMaximumFileSize = 50 * 1_024 * 1_024

    private let maximumFileSize: Int
    private let validator: BackupDocumentValidator

    // MARK: - Initializer

    init(
        maximumFileSize: Int = BackupImportService.defaultMaximumFileSize,
        calendar: Calendar = .current
    ) {
        precondition(maximumFileSize > 0)
        self.maximumFileSize = maximumFileSize
        self.validator = BackupDocumentValidator(
            calendar: calendar
        )
    }

    // MARK: - Public Methods

    func prepareImport(
        from url: URL
    ) async throws -> PreparedBackupImport {
        try Task.checkCancellation()

        let data = try readData(
            from: url
        )

        try Task.checkCancellation()

        let document = try decodeDocument(
            from: data
        )

        try Task.checkCancellation()

        return PreparedBackupImport(
            preview: BackupImportPreview(
                fileName: url.lastPathComponent,
                createdAt: document.createdAt,
                appVersion: document.appVersion,
                buildNumber: document.buildNumber,
                waterEntryCount: document.entries.count,
                goalHistoryCount: document.goalHistory.count,
                streakDayCount: document.streakDays.count,
                fileSize: data.count
            ),
            data: data
        )
    }

    // MARK: - Private Methods

    private func readData(
        from url: URL
    ) throws -> Data {
        let isAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if isAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        var coordinatedData: Data?
        var readError: Error?
        var coordinationError: NSError?
        let coordinator = NSFileCoordinator()

        coordinator.coordinate(
            readingItemAt: url,
            options: [],
            error: &coordinationError
        ) { coordinatedURL in
            do {
                let resourceValues = try coordinatedURL.resourceValues(
                    forKeys: [.fileSizeKey]
                )

                if let fileSize = resourceValues.fileSize,
                   fileSize > maximumFileSize {
                    throw BackupImportError.fileTooLarge
                }

                let data = try Data(
                    contentsOf: coordinatedURL
                )

                guard data.count <= maximumFileSize else {
                    throw BackupImportError.fileTooLarge
                }

                coordinatedData = data
            } catch {
                readError = error
            }
        }

        if let error = readError ?? coordinationError {
            if error is CancellationError {
                throw error
            }

            if let importError = error as? BackupImportError {
                throw importError
            }

            throw BackupImportError.cannotReadFile
        }

        guard let coordinatedData else {
            throw BackupImportError.cannotReadFile
        }

        return coordinatedData
    }

    private func decodeDocument(
        from data: Data
    ) throws -> BackupDocumentV1 {
        let document: BackupDocumentV1

        do {
            document = try BackupJSONCoder.makeDecoder().decode(
                BackupDocumentV1.self,
                from: data
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw BackupImportError.malformedBackup
        }

        do {
            try validator.validate(document)
        } catch let error as BackupDocumentValidationError {
            switch error {
            case .invalidFormat:
                throw BackupImportError.invalidFormat
            case .unsupportedSchemaVersion:
                throw BackupImportError.unsupportedSchemaVersion
            case .invalidData:
                throw BackupImportError.invalidData
            }
        }

        return document
    }
}
