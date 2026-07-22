//
//  BackupRestoreServiceTests.swift
//  JustWaterTests
//
//  Created by сонный on 22.07.2026.
//

import Foundation
import SwiftData
import XCTest
@testable import JustWater

@MainActor
final class BackupRestoreServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        AppSettingsStorageTestSupport.setUpIsolatedDefaults()
    }

    override func tearDown() {
        AppSettingsStorageTestSupport.tearDownIsolatedDefaults()
        super.tearDown()
    }

    func testMergeRestore_emptyStoreInsertsAllDataAndPreservesValues() async throws {
        let container = try makeContainer()
        let entryID = UUID()
        let goalID = UUID()
        let entryDate = fixedDate.addingTimeInterval(3_600)
        let goalDate = fixedDate.addingTimeInterval(86_400)
        let streakDate = fixedDate.addingTimeInterval(172_800)
        let document = makeDocument(
            entries: [
                BackupWaterEntryV1(
                    id: entryID,
                    amount: 330,
                    date: entryDate,
                    drinkTypeRawValue: DrinkType.tea.rawValue
                )
            ],
            goalHistory: [
                BackupWaterGoalV1(
                    id: goalID,
                    dailyGoal: 2_700,
                    effectiveDate: goalDate
                )
            ],
            streakDays: [
                BackupStreakDayV1(
                    dayStartDate: streakDate,
                    createdAt: streakDate.addingTimeInterval(30)
                )
            ]
        )
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )

        let result = try await service.mergeRestore(
            preparedImport(for: document)
        )

        XCTAssertEqual(
            result.waterEntries,
            MergeRestoreCounts(inserted: 1, unchanged: 0, conflicts: 0)
        )
        XCTAssertEqual(
            result.goalHistory,
            MergeRestoreCounts(inserted: 1, unchanged: 0, conflicts: 0)
        )
        XCTAssertEqual(
            result.streakDays,
            MergeRestoreCounts(inserted: 1, unchanged: 0, conflicts: 0)
        )
        XCTAssertEqual(result.resolvedDailyGoal, 2_700)
        XCTAssertEqual(AppSettingsStorage.dailyGoal, 2_700)

        let entries = try fetch(WaterEntryEntity.self, from: container)
        let goals = try fetch(WaterGoalEntity.self, from: container)
        let streakDays = try fetch(HydrationStreakDayEntity.self, from: container)
        let entry = try XCTUnwrap(entries.first)
        let goal = try XCTUnwrap(goals.first)
        let streakDay = try XCTUnwrap(streakDays.first)

        XCTAssertEqual(entry.id, entryID)
        XCTAssertEqual(entry.amount, 330)
        XCTAssertEqual(entry.date, entryDate)
        XCTAssertEqual(entry.drinkTypeRawValue, DrinkType.tea.rawValue)
        XCTAssertEqual(goal.id, goalID)
        XCTAssertEqual(goal.dailyGoal, 2_700)
        XCTAssertEqual(goal.effectiveDate, calendar.startOfDay(for: goalDate))
        XCTAssertEqual(streakDay.dayStartDate, calendar.startOfDay(for: streakDate))
        XCTAssertEqual(streakDay.createdAt, streakDate.addingTimeInterval(30))
    }

    func testMergeRestore_mixedBackupReportsInsertedUnchangedAndConflicts() async throws {
        let container = try makeContainer()
        let unchangedID = UUID()
        let conflictID = UUID()
        let insertedID = UUID()
        try insert(
            [
                WaterEntryEntity(
                    id: unchangedID,
                    amount: 250,
                    date: fixedDate,
                    drinkTypeRawValue: DrinkType.water.rawValue
                ),
                WaterEntryEntity(
                    id: conflictID,
                    amount: 500,
                    date: fixedDate,
                    drinkTypeRawValue: DrinkType.coffee.rawValue
                )
            ],
            into: container
        )
        let document = makeDocument(
            entries: [
                BackupWaterEntryV1(
                    id: unchangedID,
                    amount: 250,
                    date: fixedDate,
                    drinkTypeRawValue: DrinkType.water.rawValue
                ),
                BackupWaterEntryV1(
                    id: conflictID,
                    amount: 900,
                    date: fixedDate.addingTimeInterval(60),
                    drinkTypeRawValue: DrinkType.tea.rawValue
                ),
                BackupWaterEntryV1(
                    id: insertedID,
                    amount: 300,
                    date: fixedDate,
                    drinkTypeRawValue: DrinkType.water.rawValue
                )
            ]
        )
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )

        let result = try await service.mergeRestore(
            preparedImport(for: document)
        )

        XCTAssertEqual(
            result.waterEntries,
            MergeRestoreCounts(inserted: 1, unchanged: 1, conflicts: 1)
        )
        XCTAssertEqual(result.waterEntries.skipped, 2)
        XCTAssertEqual(
            try fetch(WaterEntryEntity.self, from: container).count,
            3
        )
        let localConflict = try XCTUnwrap(
            try fetch(WaterEntryEntity.self, from: container)
                .first { $0.id == conflictID }
        )
        XCTAssertEqual(localConflict.amount, 500)
        XCTAssertEqual(localConflict.date, fixedDate)
        XCTAssertEqual(localConflict.drinkTypeRawValue, DrinkType.coffee.rawValue)
    }

    func testMergeRestore_goalWithSameNormalizedDayKeepsLocalRecord() async throws {
        let container = try makeContainer()
        let localID = UUID()
        let localDate = calendar.startOfDay(for: fixedDate)
        try insert(
            [
                WaterGoalEntity(
                    id: localID,
                    dailyGoal: 2_200,
                    effectiveDate: localDate
                )
            ],
            into: container
        )
        let document = makeDocument(
            goalHistory: [
                BackupWaterGoalV1(
                    id: UUID(),
                    dailyGoal: 3_000,
                    effectiveDate: localDate.addingTimeInterval(43_200)
                )
            ]
        )
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )

        let result = try await service.mergeRestore(
            preparedImport(for: document)
        )

        XCTAssertEqual(
            result.goalHistory,
            MergeRestoreCounts(inserted: 0, unchanged: 0, conflicts: 1)
        )
        XCTAssertEqual(result.resolvedDailyGoal, 2_200)
        let goals = try fetch(WaterGoalEntity.self, from: container)
        XCTAssertEqual(goals.count, 1)
        XCTAssertEqual(goals.first?.id, localID)
        XCTAssertEqual(goals.first?.dailyGoal, 2_200)
    }

    func testMergeRestore_goalWithSameIDAndDifferentValuesKeepsLocalRecord() async throws {
        let container = try makeContainer()
        let goalID = UUID()
        let localDate = calendar.startOfDay(for: fixedDate)
        try insert(
            [
                WaterGoalEntity(
                    id: goalID,
                    dailyGoal: 2_200,
                    effectiveDate: localDate
                )
            ],
            into: container
        )
        let document = makeDocument(
            goalHistory: [
                BackupWaterGoalV1(
                    id: goalID,
                    dailyGoal: 3_000,
                    effectiveDate: localDate.addingTimeInterval(86_400)
                )
            ]
        )
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )

        let result = try await service.mergeRestore(
            preparedImport(for: document)
        )

        XCTAssertEqual(
            result.goalHistory,
            MergeRestoreCounts(inserted: 0, unchanged: 0, conflicts: 1)
        )
        let goals = try fetch(WaterGoalEntity.self, from: container)
        XCTAssertEqual(goals.count, 1)
        XCTAssertEqual(goals.first?.id, goalID)
        XCTAssertEqual(goals.first?.dailyGoal, 2_200)
        XCTAssertEqual(goals.first?.effectiveDate, localDate)
    }

    func testMergeRestore_streakWithSameNormalizedDayKeepsLocalRecord() async throws {
        let container = try makeContainer()
        let localDate = calendar.startOfDay(for: fixedDate)
        let localCreatedAt = fixedDate.addingTimeInterval(-60)
        try insert(
            [
                HydrationStreakDayEntity(
                    dayStartDate: localDate,
                    createdAt: localCreatedAt
                )
            ],
            into: container
        )
        let document = makeDocument(
            streakDays: [
                BackupStreakDayV1(
                    dayStartDate: localDate.addingTimeInterval(43_200),
                    createdAt: fixedDate
                )
            ]
        )
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )

        let result = try await service.mergeRestore(
            preparedImport(for: document)
        )

        XCTAssertEqual(
            result.streakDays,
            MergeRestoreCounts(inserted: 0, unchanged: 0, conflicts: 1)
        )
        let streakDays = try fetch(HydrationStreakDayEntity.self, from: container)
        XCTAssertEqual(streakDays.count, 1)
        XCTAssertEqual(streakDays.first?.createdAt, localCreatedAt)
    }

    func testMergeRestore_repeatedMergeIsIdempotent() async throws {
        let container = try makeContainer()
        let document = makeDocument(
            entries: [
                BackupWaterEntryV1(
                    id: UUID(),
                    amount: 250,
                    date: fixedDate,
                    drinkTypeRawValue: DrinkType.water.rawValue
                )
            ],
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
        let preparedImport = try preparedImport(for: document)
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )

        _ = try await service.mergeRestore(preparedImport)
        let secondResult = try await service.mergeRestore(preparedImport)

        XCTAssertEqual(
            secondResult.waterEntries,
            MergeRestoreCounts(inserted: 0, unchanged: 1, conflicts: 0)
        )
        XCTAssertEqual(
            secondResult.goalHistory,
            MergeRestoreCounts(inserted: 0, unchanged: 1, conflicts: 0)
        )
        XCTAssertEqual(
            secondResult.streakDays,
            MergeRestoreCounts(inserted: 0, unchanged: 1, conflicts: 0)
        )
        XCTAssertFalse(secondResult.hasInsertedData)
        XCTAssertEqual(try totalObjectCount(in: container), 3)
    }

    func testMergeRestore_emptyBackupReturnsZeroCounts() async throws {
        let container = try makeContainer()
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )

        let result = try await service.mergeRestore(
            preparedImport(
                for: makeDocument(fallbackDailyGoal: 2_400)
            )
        )

        let zeroCounts = MergeRestoreCounts(
            inserted: 0,
            unchanged: 0,
            conflicts: 0
        )
        XCTAssertEqual(result.waterEntries, zeroCounts)
        XCTAssertEqual(result.goalHistory, zeroCounts)
        XCTAssertEqual(result.streakDays, zeroCounts)
        XCTAssertEqual(result.resolvedDailyGoal, 2_400)
        XCTAssertEqual(try totalObjectCount(in: container), 0)
    }

    func testMergeRestore_resolvesLatestGoalFromMergedHistory() async throws {
        let container = try makeContainer()
        let olderDate = fixedDate.addingTimeInterval(-172_800)
        let newerDate = fixedDate.addingTimeInterval(172_800)
        try insert(
            [
                WaterGoalEntity(
                    dailyGoal: 2_100,
                    effectiveDate: olderDate
                )
            ],
            into: container
        )
        let document = makeDocument(
            goalHistory: [
                BackupWaterGoalV1(
                    id: UUID(),
                    dailyGoal: 2_900,
                    effectiveDate: newerDate
                )
            ],
            fallbackDailyGoal: 1_800
        )
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )

        let result = try await service.mergeRestore(
            preparedImport(for: document)
        )

        XCTAssertEqual(result.resolvedDailyGoal, 2_900)
        XCTAssertEqual(AppSettingsStorage.dailyGoal, 2_900)
    }

    func testMergeRestore_emptyGoalHistoryUsesBackupFallbackOnlyForDailyGoal() async throws {
        let container = try makeContainer()
        AppSettingsStorage.isHapticsEnabled = true
        AppSettingsStorage.measurementUnit = .fluidOunces
        let document = makeDocument(
            fallbackDailyGoal: 2_650
        )
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )

        let result = try await service.mergeRestore(
            preparedImport(for: document)
        )

        XCTAssertEqual(result.resolvedDailyGoal, 2_650)
        XCTAssertEqual(AppSettingsStorage.dailyGoal, 2_650)
        XCTAssertTrue(AppSettingsStorage.isHapticsEnabled)
        XCTAssertEqual(AppSettingsStorage.measurementUnit, .fluidOunces)
    }

    func testMergeRestore_invalidPreparedBackupDoesNotChangeStoredData() async throws {
        let container = try makeContainer()
        try insert(
            [
                WaterEntryEntity(
                    amount: 200,
                    date: fixedDate
                )
            ],
            into: container
        )
        let initialGoal = AppSettingsStorage.dailyGoal
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )
        let preparedImport = PreparedBackupImport(
            preview: makePreview(fileSize: 8),
            data: Data("not-json".utf8)
        )

        await assertRestoreError(.invalidPreparedBackup) {
            try await service.mergeRestore(preparedImport)
        }

        XCTAssertEqual(try totalObjectCount(in: container), 1)
        XCTAssertEqual(AppSettingsStorage.dailyGoal, initialGoal)
    }

    func testMergeRestore_unsupportedSchemaDoesNotChangeStoredData() async throws {
        let container = try makeContainer()
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )
        let document = makeDocument(
            schemaVersion: BackupDocumentV1.schemaVersion + 1,
            entries: [
                BackupWaterEntryV1(
                    id: UUID(),
                    amount: 250,
                    date: fixedDate,
                    drinkTypeRawValue: DrinkType.water.rawValue
                )
            ]
        )

        await assertRestoreError(.invalidPreparedBackup) {
            try await service.mergeRestore(
                preparedImport(for: document)
            )
        }

        XCTAssertEqual(try totalObjectCount(in: container), 0)
    }

    func testMergeRestore_saveFailureRollsBackAllChangesAndDoesNotUpdateGoalCache() async throws {
        let container = try makeReadOnlyContainer()
        AppSettingsStorage.dailyGoal = 2_000
        let document = makeDocument(
            entries: [
                BackupWaterEntryV1(
                    id: UUID(),
                    amount: 250,
                    date: fixedDate,
                    drinkTypeRawValue: DrinkType.water.rawValue
                )
            ],
            goalHistory: [
                BackupWaterGoalV1(
                    id: UUID(),
                    dailyGoal: 3_000,
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
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )

        await assertRestoreError(.persistenceFailed) {
            try await service.mergeRestore(
                preparedImport(for: document)
            )
        }

        XCTAssertEqual(try totalObjectCount(in: container), 0)
        XCTAssertEqual(AppSettingsStorage.dailyGoal, 2_000)
    }

    func testMergeRestore_cancelledTaskDoesNotWriteDataOrUpdateGoalCache() async throws {
        let container = try makeContainer()
        AppSettingsStorage.dailyGoal = 2_000
        let document = makeDocument(
            entries: [
                BackupWaterEntryV1(
                    id: UUID(),
                    amount: 250,
                    date: fixedDate,
                    drinkTypeRawValue: DrinkType.water.rawValue
                )
            ],
            fallbackDailyGoal: 3_000
        )
        let preparedImport = try preparedImport(for: document)
        let service = BackupRestoreService(
            modelContainer: container,
            calendar: calendar
        )
        let task = Task {
            try await service.mergeRestore(preparedImport)
        }

        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected merge restore to be cancelled.")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }
        XCTAssertEqual(try totalObjectCount(in: container), 0)
        XCTAssertEqual(AppSettingsStorage.dailyGoal, 2_000)
    }

    // MARK: - Helpers

    private var fixedDate: Date {
        Date(timeIntervalSince1970: 1_779_876_543.123)
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        if let utc = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = utc
        }
        return calendar
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

    private func makeReadOnlyContainer() throws -> ModelContainer {
        let schema = Schema([
            WaterEntryEntity.self,
            WaterGoalEntity.self,
            HydrationStreakDayEntity.self
        ])
        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("store")
        try createEmptyStore(
            schema: schema,
            at: storeURL
        )

        let configuration = ModelConfiguration(
            "BackupRestoreReadOnly",
            schema: schema,
            url: storeURL,
            allowsSave: false
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    private func createEmptyStore(
        schema: Schema,
        at url: URL
    ) throws {
        let configuration = ModelConfiguration(
            "BackupRestoreWritable",
            schema: schema,
            url: url,
            allowsSave: true
        )
        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        try container.mainContext.save()
    }

    private func makeDocument(
        format: String = BackupDocumentV1.format,
        schemaVersion: Int = BackupDocumentV1.schemaVersion,
        entries: [BackupWaterEntryV1] = [],
        goalHistory: [BackupWaterGoalV1] = [],
        streakDays: [BackupStreakDayV1] = [],
        fallbackDailyGoal: Int = 2_000
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
                dailyGoal: fallbackDailyGoal,
                isHapticsEnabled: false,
                appearanceModeRawValue: AppAppearanceMode.system.rawValue,
                measurementUnitRawValue: MeasurementUnit.milliliters.rawValue,
                areRemindersEnabled: false,
                reminderStartHour: 9,
                reminderEndHour: 21,
                reminderFrequencyRawValue: ReminderFrequency.twoHours.rawValue,
                isHealthSyncEnabled: false
            )
        )
    }

    private func preparedImport(
        for document: BackupDocumentV1
    ) throws -> PreparedBackupImport {
        let data = try BackupJSONCoder.makeEncoder().encode(document)

        return PreparedBackupImport(
            preview: makePreview(fileSize: data.count),
            data: data
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
            waterEntryCount: 0,
            goalHistoryCount: 0,
            streakDayCount: 0,
            fileSize: fileSize
        )
    }

    private func insert<T: PersistentModel>(
        _ entities: [T],
        into container: ModelContainer
    ) throws {
        let context = ModelContext(container)
        for entity in entities {
            context.insert(entity)
        }
        try context.save()
    }

    private func fetch<T: PersistentModel>(
        _ modelType: T.Type,
        from container: ModelContainer
    ) throws -> [T] {
        let context = ModelContext(container)
        return try context.fetch(FetchDescriptor<T>())
    }

    private func totalObjectCount(
        in container: ModelContainer
    ) throws -> Int {
        try fetch(WaterEntryEntity.self, from: container).count
        + fetch(WaterGoalEntity.self, from: container).count
        + fetch(HydrationStreakDayEntity.self, from: container).count
    }

    private func assertRestoreError(
        _ expectedError: BackupRestoreError,
        operation: () async throws -> MergeRestoreResult
    ) async {
        do {
            _ = try await operation()
            XCTFail("Expected restore to fail with \(expectedError).")
        } catch {
            XCTAssertEqual(
                error as? BackupRestoreError,
                expectedError
            )
        }
    }
}
