//
//  BackupValidationConsistencyTests.swift
//  JustWaterTests
//
//  Created by сонный on 22.07.2026.
//

import Foundation
import SwiftData
import XCTest
@testable import JustWater

@MainActor
final class BackupValidationConsistencyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        AppSettingsStorageTestSupport.setUpIsolatedDefaults()
    }

    override func tearDown() {
        AppSettingsStorageTestSupport.tearDownIsolatedDefaults()
        super.tearDown()
    }

    func testValidation_multipleGoalsOnSameNormalizedDay_areRejectedConsistently() async throws {
        let dayStart = calendar.startOfDay(for: fixedDate)
        let document = makeDocument(
            goalHistory: [
                BackupWaterGoalV1(
                    id: UUID(),
                    dailyGoal: 2_200,
                    effectiveDate: dayStart.addingTimeInterval(3_600)
                ),
                BackupWaterGoalV1(
                    id: UUID(),
                    dailyGoal: 2_800,
                    effectiveDate: dayStart.addingTimeInterval(64_800)
                )
            ]
        )

        try await assertValidation(
            of: document,
            isAccepted: false
        )
    }

    func testValidation_multipleStreakDaysOnSameNormalizedDay_areRejectedConsistently() async throws {
        let dayStart = calendar.startOfDay(for: fixedDate)
        let document = makeDocument(
            streakDays: [
                BackupStreakDayV1(
                    dayStartDate: dayStart.addingTimeInterval(1_800),
                    createdAt: fixedDate
                ),
                BackupStreakDayV1(
                    dayStartDate: dayStart.addingTimeInterval(72_000),
                    createdAt: fixedDate.addingTimeInterval(60)
                )
            ]
        )

        try await assertValidation(
            of: document,
            isAccepted: false
        )
    }

    func testValidation_invalidReminderHour_isRejectedConsistently() async throws {
        let document = makeDocument(
            reminderStartHour: 24
        )

        try await assertValidation(
            of: document,
            isAccepted: false
        )
    }

    func testValidation_validDocument_isAcceptedConsistently() async throws {
        let document = makeDocument(
            goalHistory: [
                BackupWaterGoalV1(
                    id: UUID(),
                    dailyGoal: 2_500,
                    effectiveDate: fixedDate
                )
            ],
            streakDays: [
                BackupStreakDayV1(
                    dayStartDate: fixedDate,
                    createdAt: fixedDate
                )
            ]
        )

        try await assertValidation(
            of: document,
            isAccepted: true
        )
    }

    private var fixedDate: Date {
        Date(timeIntervalSince1970: 1_774_000_272.123)
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private func assertValidation(
        of document: BackupDocumentV1,
        isAccepted: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        let data = try BackupJSONCoder.makeEncoder().encode(document)
        let previewIsAccepted = try await previewAccepts(data)
        let mergeIsAccepted = try await restoreAccepts(
            data,
            operation: .merge
        )
        let replaceIsAccepted = try await restoreAccepts(
            data,
            operation: .replace
        )

        XCTAssertEqual(
            previewIsAccepted,
            isAccepted,
            "Preview validation differs from the expected contract.",
            file: file,
            line: line
        )
        XCTAssertEqual(
            mergeIsAccepted,
            isAccepted,
            "Merge validation differs from the expected contract.",
            file: file,
            line: line
        )
        XCTAssertEqual(
            replaceIsAccepted,
            isAccepted,
            "Replace validation differs from the expected contract.",
            file: file,
            line: line
        )
    }

    private func previewAccepts(
        _ data: Data
    ) async throws -> Bool {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        try data.write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        do {
            _ = try await BackupImportService(
                calendar: calendar
            ).prepareImport(from: url)
            return true
        } catch BackupImportError.invalidData {
            return false
        }
    }

    private func restoreAccepts(
        _ data: Data,
        operation: RestoreOperation
    ) async throws -> Bool {
        let service = BackupRestoreService(
            modelContainer: try makeContainer(),
            calendar: calendar
        )
        let preparedImport = PreparedBackupImport(
            preview: makePreview(fileSize: data.count),
            data: data
        )

        do {
            switch operation {
            case .merge:
                _ = try await service.mergeRestore(preparedImport)
            case .replace:
                _ = try await service.replaceRestore(preparedImport)
            }
            return true
        } catch BackupRestoreError.invalidPreparedBackup {
            return false
        }
    }

    private func makeDocument(
        goalHistory: [BackupWaterGoalV1] = [],
        streakDays: [BackupStreakDayV1] = [],
        reminderStartHour: Int = 9
    ) -> BackupDocumentV1 {
        BackupDocumentV1(
            appVersion: "1.2",
            buildNumber: "45",
            createdAt: fixedDate,
            entries: [
                BackupWaterEntryV1(
                    id: UUID(),
                    amount: 250,
                    date: fixedDate,
                    drinkTypeRawValue: DrinkType.water.rawValue
                )
            ],
            goalHistory: goalHistory,
            streakDays: streakDays,
            settings: BackupSettingsV1(
                dailyGoal: 2_500,
                isHapticsEnabled: true,
                appearanceModeRawValue: AppAppearanceMode.system.rawValue,
                measurementUnitRawValue: MeasurementUnit.milliliters.rawValue,
                areRemindersEnabled: false,
                reminderStartHour: reminderStartHour,
                reminderEndHour: 22,
                reminderFrequencyRawValue: ReminderFrequency.twoHours.rawValue,
                isHealthSyncEnabled: false
            )
        )
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            WaterEntryEntity.self,
            WaterGoalEntity.self,
            HydrationStreakDayEntity.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    private func makePreview(
        fileSize: Int
    ) -> BackupImportPreview {
        BackupImportPreview(
            fileName: "JustWaterBackup.json",
            createdAt: fixedDate,
            appVersion: "1.2",
            buildNumber: "45",
            waterEntryCount: 1,
            goalHistoryCount: 0,
            streakDayCount: 0,
            fileSize: fileSize
        )
    }
}

private enum RestoreOperation {
    case merge
    case replace
}
