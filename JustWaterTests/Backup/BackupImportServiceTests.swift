//
//  BackupImportServiceTests.swift
//  JustWaterTests
//
//  Created by сонный on 22.07.2026.
//

import Foundation
import XCTest
@testable import JustWater

@MainActor
final class BackupImportServiceTests: XCTestCase {

    private var temporaryDirectories: [URL] = []

    override func tearDown() {
        for directory in temporaryDirectories {
            try? FileManager.default.removeItem(
                at: directory
            )
        }

        temporaryDirectories = []
        super.tearDown()
    }

    func testPrepareImport_validVersionOneBackupBuildsExpectedPreview() async throws {
        let entries = [
            BackupWaterEntryV1(
                id: UUID(),
                amount: 250,
                date: fixedDate,
                drinkTypeRawValue: DrinkType.water.rawValue
            ),
            BackupWaterEntryV1(
                id: UUID(),
                amount: 330,
                date: fixedDate.addingTimeInterval(60),
                drinkTypeRawValue: DrinkType.tea.rawValue
            )
        ]
        let goalHistory = [
            BackupWaterGoalV1(
                id: UUID(),
                dailyGoal: 2_500,
                effectiveDate: fixedDate
            )
        ]
        let streakDays = [
            BackupStreakDayV1(
                dayStartDate: fixedDate,
                createdAt: fixedDate
            )
        ]
        let data = try encode(
            makeDocument(
                entries: entries,
                goalHistory: goalHistory,
                streakDays: streakDays
            )
        )
        let url = try write(
            data,
            fileName: "JustWaterBackup.json"
        )
        let service = BackupImportService()

        let preparedImport = try await service.prepareImport(
            from: url
        )

        XCTAssertEqual(
            preparedImport.preview,
            BackupImportPreview(
                fileName: "JustWaterBackup.json",
                createdAt: fixedDate,
                appVersion: "1.2",
                buildNumber: "45",
                waterEntryCount: 2,
                goalHistoryCount: 1,
                streakDayCount: 1,
                fileSize: data.count
            )
        )
    }

    func testPrepareImport_preservesOriginalDataWithoutReencoding() async throws {
        let data = try encode(
            makeDocument()
        )
        let url = try write(data)
        let service = BackupImportService()

        let preparedImport = try await service.prepareImport(
            from: url
        )

        XCTAssertEqual(
            preparedImport.data,
            data
        )
    }

    func testPrepareImport_acceptsDatesWithFractionalSeconds() async throws {
        let data = try encode(
            makeDocument()
        )
        let json = try XCTUnwrap(
            String(
                data: data,
                encoding: .utf8
            )
        )
        let url = try write(data)
        let service = BackupImportService()

        let preparedImport = try await service.prepareImport(
            from: url
        )

        XCTAssertTrue(json.contains(".123Z"))
        XCTAssertEqual(
            preparedImport.preview.createdAt.timeIntervalSince1970,
            fixedDate.timeIntervalSince1970,
            accuracy: 0.001
        )
    }

    func testPrepareImport_acceptsDateWithoutFractionalSeconds() async throws {
        var jsonObject = try jsonObject(
            from: encode(
                makeDocument()
            )
        )
        jsonObject["createdAt"] = "2026-07-20T10:11:12Z"
        let data = try JSONSerialization.data(
            withJSONObject: jsonObject,
            options: [.sortedKeys]
        )
        let url = try write(data)
        let service = BackupImportService()

        let preparedImport = try await service.prepareImport(
            from: url
        )

        XCTAssertEqual(
            preparedImport.preview.createdAt,
            expectedWholeSecondDate
        )
    }

    func testPrepareImport_invalidFormatThrowsTypedError() async throws {
        let data = try encode(
            makeDocument(
                format: "example.invalid.backup"
            )
        )
        let url = try write(data)
        let service = BackupImportService()

        await assertImportError(.invalidFormat) {
            try await service.prepareImport(
                from: url
            )
        }
    }

    func testPrepareImport_unsupportedSchemaVersionThrowsTypedError() async throws {
        let data = try encode(
            makeDocument(
                schemaVersion: 2
            )
        )
        let url = try write(data)
        let service = BackupImportService()

        await assertImportError(.unsupportedSchemaVersion) {
            try await service.prepareImport(
                from: url
            )
        }
    }

    func testPrepareImport_malformedJSONThrowsTypedError() async throws {
        let url = try write(
            Data("{not-json}".utf8)
        )
        let service = BackupImportService()

        await assertImportError(.malformedBackup) {
            try await service.prepareImport(
                from: url
            )
        }
    }

    func testPrepareImport_missingRequiredFieldThrowsTypedError() async throws {
        var jsonObject = try jsonObject(
            from: encode(
                makeDocument()
            )
        )
        jsonObject.removeValue(
            forKey: "settings"
        )
        let data = try JSONSerialization.data(
            withJSONObject: jsonObject
        )
        let url = try write(data)
        let service = BackupImportService()

        await assertImportError(.malformedBackup) {
            try await service.prepareImport(
                from: url
            )
        }
    }

    func testPrepareImport_duplicateEntryIDThrowsInvalidData() async throws {
        let id = UUID()
        let entries = [
            BackupWaterEntryV1(
                id: id,
                amount: 250,
                date: fixedDate,
                drinkTypeRawValue: DrinkType.water.rawValue
            ),
            BackupWaterEntryV1(
                id: id,
                amount: 300,
                date: fixedDate,
                drinkTypeRawValue: DrinkType.tea.rawValue
            )
        ]
        let url = try write(
            encode(
                makeDocument(
                    entries: entries
                )
            )
        )
        let service = BackupImportService()

        await assertImportError(.invalidData) {
            try await service.prepareImport(
                from: url
            )
        }
    }

    func testPrepareImport_duplicateGoalIDThrowsInvalidData() async throws {
        let id = UUID()
        let goals = [
            BackupWaterGoalV1(
                id: id,
                dailyGoal: 2_500,
                effectiveDate: fixedDate
            ),
            BackupWaterGoalV1(
                id: id,
                dailyGoal: 2_700,
                effectiveDate: fixedDate.addingTimeInterval(60)
            )
        ]
        let url = try write(
            encode(
                makeDocument(
                    goalHistory: goals
                )
            )
        )
        let service = BackupImportService()

        await assertImportError(.invalidData) {
            try await service.prepareImport(
                from: url
            )
        }
    }

    func testPrepareImport_duplicateStreakDateThrowsInvalidData() async throws {
        let streakDays = [
            BackupStreakDayV1(
                dayStartDate: fixedDate,
                createdAt: fixedDate
            ),
            BackupStreakDayV1(
                dayStartDate: fixedDate,
                createdAt: fixedDate.addingTimeInterval(60)
            )
        ]
        let url = try write(
            encode(
                makeDocument(
                    streakDays: streakDays
                )
            )
        )
        let service = BackupImportService()

        await assertImportError(.invalidData) {
            try await service.prepareImport(
                from: url
            )
        }
    }

    func testPrepareImport_invalidEntryAmountThrowsInvalidData() async throws {
        let entry = BackupWaterEntryV1(
            id: UUID(),
            amount: 0,
            date: fixedDate,
            drinkTypeRawValue: DrinkType.water.rawValue
        )
        let url = try write(
            encode(
                makeDocument(
                    entries: [entry]
                )
            )
        )
        let service = BackupImportService()

        await assertImportError(.invalidData) {
            try await service.prepareImport(
                from: url
            )
        }
    }

    func testPrepareImport_oversizedFileThrowsTypedError() async throws {
        let data = try encode(
            makeDocument()
        )
        let url = try write(data)
        let service = BackupImportService(
            maximumFileSize: data.count - 1
        )

        await assertImportError(.fileTooLarge) {
            try await service.prepareImport(
                from: url
            )
        }
    }

    func testPrepareImport_unreadableURLThrowsTypedError() async throws {
        let directory = makeTemporaryDirectoryURL()
        temporaryDirectories.append(directory)
        let url = directory.appendingPathComponent(
            "missing.json"
        )
        let service = BackupImportService()

        await assertImportError(.cannotReadFile) {
            try await service.prepareImport(
                from: url
            )
        }
    }

    func testPrepareImport_emptyArraysAreValid() async throws {
        let data = try encode(
            makeDocument()
        )
        let url = try write(data)
        let service = BackupImportService()

        let preparedImport = try await service.prepareImport(
            from: url
        )

        XCTAssertEqual(preparedImport.preview.waterEntryCount, 0)
        XCTAssertEqual(preparedImport.preview.goalHistoryCount, 0)
        XCTAssertEqual(preparedImport.preview.streakDayCount, 0)
    }

    // MARK: - Helpers

    private var fixedDate: Date {
        Date(
            timeIntervalSince1970: 1_774_000_272.123
        )
    }

    private var expectedWholeSecondDate: Date {
        var components = DateComponents()
        components.calendar = Calendar(
            identifier: .gregorian
        )
        components.timeZone = TimeZone(
            secondsFromGMT: 0
        )
        components.year = 2026
        components.month = 7
        components.day = 20
        components.hour = 10
        components.minute = 11
        components.second = 12

        return components.date ?? .distantPast
    }

    private func makeDocument(
        format: String = BackupDocumentV1.format,
        schemaVersion: Int = BackupDocumentV1.schemaVersion,
        entries: [BackupWaterEntryV1] = [],
        goalHistory: [BackupWaterGoalV1] = [],
        streakDays: [BackupStreakDayV1] = []
    ) -> BackupDocumentV1 {
        BackupDocumentV1(
            format: format,
            schemaVersion: schemaVersion,
            appVersion: "1.2",
            buildNumber: "45",
            createdAt: fixedDate,
            entries: entries,
            goalHistory: goalHistory,
            streakDays: streakDays,
            settings: BackupSettingsV1(
                dailyGoal: 2_500,
                isHapticsEnabled: true,
                appearanceModeRawValue: AppAppearanceMode.system.rawValue,
                measurementUnitRawValue: MeasurementUnit.milliliters.rawValue,
                areRemindersEnabled: false,
                reminderStartHour: 9,
                reminderEndHour: 22,
                reminderFrequencyRawValue: ReminderFrequency.twoHours.rawValue,
                isHealthSyncEnabled: false
            )
        )
    }

    private func encode(
        _ document: BackupDocumentV1
    ) throws -> Data {
        try BackupJSONCoder.makeEncoder().encode(
            document
        )
    }

    private func jsonObject(
        from data: Data
    ) throws -> [String: Any] {
        try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
    }

    private func write(
        _ data: Data,
        fileName: String = "backup.json"
    ) throws -> URL {
        let directory = makeTemporaryDirectoryURL()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        temporaryDirectories.append(directory)

        let url = directory.appendingPathComponent(
            fileName
        )
        try data.write(
            to: url
        )

        return url
    }

    private func makeTemporaryDirectoryURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(
                UUID().uuidString,
                isDirectory: true
            )
    }

    private func assertImportError(
        _ expectedError: BackupImportError,
        operation: () async throws -> PreparedBackupImport,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await operation()
            XCTFail(
                "Expected import to fail.",
                file: file,
                line: line
            )
        } catch {
            XCTAssertEqual(
                error as? BackupImportError,
                expectedError,
                file: file,
                line: line
            )
        }
    }
}
