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

    // MARK: - Initializer

    init(
        maximumFileSize: Int = BackupImportService.defaultMaximumFileSize
    ) {
        precondition(maximumFileSize > 0)
        self.maximumFileSize = maximumFileSize
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

        try validate(document)
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
        let header: BackupHeader

        do {
            header = try JSONDecoder().decode(
                BackupHeader.self,
                from: data
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw BackupImportError.malformedBackup
        }

        guard header.format == BackupDocumentV1.format else {
            throw BackupImportError.invalidFormat
        }

        guard header.schemaVersion == BackupDocumentV1.schemaVersion else {
            throw BackupImportError.unsupportedSchemaVersion
        }

        do {
            return try BackupJSONCoder.makeDecoder().decode(
                BackupDocumentV1.self,
                from: data
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw BackupImportError.malformedBackup
        }
    }

    private func validate(
        _ document: BackupDocumentV1
    ) throws {
        guard hasUniqueValues(document.entries.map(\.id)),
              hasUniqueValues(document.goalHistory.map(\.id)),
              hasUniqueValues(document.streakDays.map(\.dayStartDate)),
              isValid(date: document.createdAt),
              document.settings.dailyGoal > 0,
              (0...23).contains(document.settings.reminderStartHour),
              (0...23).contains(document.settings.reminderEndHour)
        else {
            throw BackupImportError.invalidData
        }

        for entry in document.entries {
            guard entry.amount > 0,
                  isValid(date: entry.date)
            else {
                throw BackupImportError.invalidData
            }
        }

        for goal in document.goalHistory {
            guard goal.dailyGoal > 0,
                  isValid(date: goal.effectiveDate)
            else {
                throw BackupImportError.invalidData
            }
        }

        for streakDay in document.streakDays {
            guard isValid(date: streakDay.dayStartDate),
                  isValid(date: streakDay.createdAt)
            else {
                throw BackupImportError.invalidData
            }
        }
    }

    private func hasUniqueValues<Value: Hashable>(
        _ values: [Value]
    ) -> Bool {
        Set(values).count == values.count
    }

    private func isValid(
        date: Date
    ) -> Bool {
        date.timeIntervalSinceReferenceDate.isFinite
    }
}

private struct BackupHeader: Decodable {
    let format: String
    let schemaVersion: Int
}
