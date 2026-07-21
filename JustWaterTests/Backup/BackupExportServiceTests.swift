//
//  BackupExportServiceTests.swift
//  JustWaterTests
//
//  Created by сонный on 20.07.2026.
//

import SwiftData
import XCTest
@testable import JustWater

@MainActor
final class BackupExportServiceTests: XCTestCase {

    private var modelContainer: ModelContainer!

    override func tearDown() {
        modelContainer = nil

        super.tearDown()
    }

    func testCreateBackup_emptyContainerCreatesValidBackup() throws {
        let service = try makeSUT()

        let result = try service.createBackup()
        let document = try decode(result.data)

        XCTAssertEqual(document.format, BackupDocumentV1.format)
        XCTAssertEqual(document.schemaVersion, BackupDocumentV1.schemaVersion)
        XCTAssertEqual(document.entries, [])
        XCTAssertEqual(document.goalHistory, [])
        XCTAssertEqual(document.streakDays, [])
        XCTAssertEqual(result.entriesCount, 0)
        XCTAssertEqual(result.goalRecordsCount, 0)
        XCTAssertEqual(result.streakDaysCount, 0)
    }

    func testCreateBackup_exportsEntriesWithOriginalValues() throws {
        let service = try makeSUT()
        let entryID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let entryDate = makeDate(
            timeIntervalSince1970: 1_779_876_543.123
        )

        insert(
            WaterEntryEntity(
                id: entryID,
                amount: 330,
                date: entryDate,
                drinkTypeRawValue: "sparkling-water"
            )
        )

        let document = try decode(
            try service.createBackup().data
        )

        XCTAssertEqual(document.entries.count, 1)
        XCTAssertEqual(document.entries.first?.id, entryID)
        XCTAssertEqual(document.entries.first?.amount, 330)

        let exportedDate = try XCTUnwrap(
            document.entries.first?.date
        )
        XCTAssertEqual(
            exportedDate.timeIntervalSince1970,
            entryDate.timeIntervalSince1970,
            accuracy: 0.001
        )
        XCTAssertEqual(document.entries.first?.drinkTypeRawValue, "sparkling-water")
    }

    func testCreateBackup_exportsGoalHistoryWithoutCreatingInitialGoal() throws {
        let service = try makeSUT()

        XCTAssertEqual(try count(WaterGoalEntity.self), 0)

        let document = try decode(
            try service.createBackup().data
        )

        XCTAssertEqual(document.goalHistory, [])
        XCTAssertEqual(try count(WaterGoalEntity.self), 0)
    }

    func testCreateBackup_exportsAllGoalHistory() throws {
        let service = try makeSUT()
        let goalID = UUID(uuidString: "22222222-2222-2222-2222-222222222222")!
        let effectiveDate = makeDate(
            timeIntervalSince1970: 1_700_000_000
        )

        insert(
            WaterGoalEntity(
                id: goalID,
                dailyGoal: 2_700,
                effectiveDate: effectiveDate
            )
        )

        let document = try decode(
            try service.createBackup().data
        )

        XCTAssertEqual(document.goalHistory.count, 1)
        XCTAssertEqual(document.goalHistory.first?.id, goalID)
        XCTAssertEqual(document.goalHistory.first?.dailyGoal, 2_700)
        XCTAssertEqual(document.goalHistory.first?.effectiveDate, effectiveDate)
    }

    func testCreateBackup_exportsStreakDays() throws {
        let service = try makeSUT()
        let dayStartDate = makeDate(
            timeIntervalSince1970: 1_766_620_800
        )
        let createdAt = makeDate(
            timeIntervalSince1970: 1_766_621_000
        )

        insert(
            HydrationStreakDayEntity(
                dayStartDate: dayStartDate,
                createdAt: createdAt
            )
        )

        let document = try decode(
            try service.createBackup().data
        )

        XCTAssertEqual(document.streakDays.count, 1)
        XCTAssertEqual(document.streakDays.first?.dayStartDate, dayStartDate)
        XCTAssertEqual(document.streakDays.first?.createdAt, createdAt)
    }

    func testCreateBackup_exportsSettings() throws {
        let settings = BackupSettingsV1(
            dailyGoal: 3_100,
            isHapticsEnabled: false,
            appearanceModeRawValue: AppAppearanceMode.dark.rawValue,
            measurementUnitRawValue: MeasurementUnit.fluidOunces.rawValue,
            areRemindersEnabled: true,
            reminderStartHour: 7,
            reminderEndHour: 21,
            reminderFrequencyRawValue: ReminderFrequency.threeHours.rawValue,
            isHealthSyncEnabled: true
        )
        let service = try makeSUT(
            settings: settings
        )

        let document = try decode(
            try service.createBackup().data
        )

        XCTAssertEqual(document.settings, settings)
    }

    func testCreateBackup_preservesDifferentGoalHistoryAndSettingsFallback() throws {
        let service = try makeSUT(
            settings: BackupSettingsV1(
                dailyGoal: 3_100,
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
        insert(
            WaterGoalEntity(
                dailyGoal: 2_700,
                effectiveDate: fixedDate
            )
        )

        let document = try decode(
            try service.createBackup().data
        )

        XCTAssertEqual(document.goalHistory.first?.dailyGoal, 2_700)
        XCTAssertEqual(document.settings.dailyGoal, 3_100)
    }

    func testCreateBackup_doesNotExportHasCompletedOnboarding() throws {
        let service = try makeSUT()

        let json = try XCTUnwrap(
            String(
                data: try service.createBackup().data,
                encoding: .utf8
            )
        )

        XCTAssertFalse(
            json.contains("hasCompletedOnboarding")
        )
    }

    func testCreateBackup_usesStableVersionOneJSONKeys() throws {
        let service = try makeSUT()

        insert(
            WaterEntryEntity(
                amount: 250,
                date: fixedDate,
                drinkTypeRawValue: "water"
            )
        )
        insert(
            WaterGoalEntity(
                dailyGoal: 2_500,
                effectiveDate: fixedDate
            )
        )
        insert(
            HydrationStreakDayEntity(
                dayStartDate: fixedDate,
                createdAt: fixedDate
            )
        )

        let jsonObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: try service.createBackup().data
            ) as? [String: Any]
        )

        XCTAssertEqual(
            Set(jsonObject.keys),
            [
                "format",
                "schemaVersion",
                "appVersion",
                "buildNumber",
                "createdAt",
                "entries",
                "goalHistory",
                "streakDays",
                "settings"
            ]
        )

        let entries = try XCTUnwrap(jsonObject["entries"] as? [[String: Any]])
        let goalHistory = try XCTUnwrap(jsonObject["goalHistory"] as? [[String: Any]])
        let streakDays = try XCTUnwrap(jsonObject["streakDays"] as? [[String: Any]])
        let settings = try XCTUnwrap(jsonObject["settings"] as? [String: Any])

        XCTAssertEqual(
            Set(try XCTUnwrap(entries.first).keys),
            ["id", "amount", "date", "drinkTypeRawValue"]
        )
        XCTAssertEqual(
            Set(try XCTUnwrap(goalHistory.first).keys),
            ["id", "dailyGoal", "effectiveDate"]
        )
        XCTAssertEqual(
            Set(try XCTUnwrap(streakDays.first).keys),
            ["dayStartDate", "createdAt"]
        )
        XCTAssertEqual(
            Set(settings.keys),
            [
                "dailyGoal",
                "isHapticsEnabled",
                "appearanceModeRawValue",
                "measurementUnitRawValue",
                "areRemindersEnabled",
                "reminderStartHour",
                "reminderEndHour",
                "reminderFrequencyRawValue",
                "isHealthSyncEnabled"
            ]
        )
    }

    func testCreateBackup_sortsDataDeterministically() throws {
        let service = try makeSUT()

        let laterEntryID = UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!
        let earlierEntryID = UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!
        let sameDateLowerID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let sameDateHigherID = UUID(uuidString: "99999999-9999-9999-9999-999999999999")!
        let sameDate = makeDate(timeIntervalSince1970: 1_700_000_000)

        insert(
            WaterEntryEntity(
                id: laterEntryID,
                amount: 300,
                date: makeDate(timeIntervalSince1970: 1_700_000_100),
                drinkTypeRawValue: "water"
            )
        )
        insert(
            WaterEntryEntity(
                id: earlierEntryID,
                amount: 200,
                date: makeDate(timeIntervalSince1970: 1_699_999_900),
                drinkTypeRawValue: "tea"
            )
        )
        insert(
            WaterEntryEntity(
                id: sameDateHigherID,
                amount: 250,
                date: sameDate,
                drinkTypeRawValue: "juice"
            )
        )
        insert(
            WaterEntryEntity(
                id: sameDateLowerID,
                amount: 260,
                date: sameDate,
                drinkTypeRawValue: "coffee"
            )
        )

        let laterGoalID = UUID(uuidString: "BBBBBBBB-0000-0000-0000-000000000000")!
        let earlierGoalID = UUID(uuidString: "AAAAAAAA-0000-0000-0000-000000000000")!
        insert(
            WaterGoalEntity(
                id: laterGoalID,
                dailyGoal: 2_600,
                effectiveDate: makeDate(timeIntervalSince1970: 1_700_000_100)
            )
        )
        insert(
            WaterGoalEntity(
                id: earlierGoalID,
                dailyGoal: 2_400,
                effectiveDate: makeDate(timeIntervalSince1970: 1_699_999_900)
            )
        )

        insert(
            HydrationStreakDayEntity(
                dayStartDate: makeDate(timeIntervalSince1970: 1_700_086_400),
                createdAt: makeDate(timeIntervalSince1970: 1_700_087_000)
            )
        )
        insert(
            HydrationStreakDayEntity(
                dayStartDate: makeDate(timeIntervalSince1970: 1_700_000_000),
                createdAt: makeDate(timeIntervalSince1970: 1_700_000_100)
            )
        )

        let document = try decode(
            try service.createBackup().data
        )

        XCTAssertEqual(
            document.entries.map(\.id),
            [
                earlierEntryID,
                sameDateLowerID,
                sameDateHigherID,
                laterEntryID
            ]
        )
        XCTAssertEqual(
            document.goalHistory.map(\.id),
            [
                earlierGoalID,
                laterGoalID
            ]
        )
        XCTAssertLessThan(
            document.streakDays[0].dayStartDate,
            document.streakDays[1].dayStartDate
        )
    }

    func testCreateBackup_jsonDecodesBackToDocument() throws {
        let service = try makeSUT()

        insert(
            WaterEntryEntity(
                amount: 250,
                date: makeDate(timeIntervalSince1970: 1_700_000_000.123),
                drinkTypeRawValue: "water"
            )
        )

        let result = try service.createBackup()
        let document = try decode(result.data)

        XCTAssertEqual(document.createdAt, fixedDate)
        XCTAssertEqual(document.entries.count, 1)
    }

    func testBackupDecoder_acceptsISO8601DateWithoutFractionalSeconds() throws {
        let service = try makeSUT()
        let data = try service.createBackup().data
        var jsonObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any]
        )
        jsonObject["createdAt"] = "2026-07-20T10:11:12Z"

        let modifiedData = try JSONSerialization.data(
            withJSONObject: jsonObject
        )
        let document = try decode(modifiedData)
        let expectedDate = makeDate(
            year: 2026,
            month: 7,
            day: 20,
            hour: 10,
            minute: 11,
            second: 12
        )

        XCTAssertEqual(document.createdAt, expectedDate)
    }

    func testCreateBackup_fixedDateCreatesExpectedMetadata() throws {
        let createdAt = makeDate(
            year: 2026,
            month: 7,
            day: 20,
            hour: 10,
            minute: 11,
            second: 12
        )
        let service = try makeSUT(
            date: createdAt
        )

        let result = try service.createBackup()
        let document = try decode(result.data)

        XCTAssertEqual(result.createdAt, createdAt)
        XCTAssertEqual(document.createdAt, createdAt)
        XCTAssertEqual(
            result.suggestedFileName,
            "JustWaterBackup-2026-07-20-101112.json"
        )
    }

    func testCreateBackup_invalidEntryAmountThrowsTypedError() throws {
        let service = try makeSUT()
        let entryID = UUID(uuidString: "33333333-3333-3333-3333-333333333333")!

        insert(
            WaterEntryEntity(
                id: entryID,
                amount: 0,
                date: fixedDate,
                drinkTypeRawValue: "water"
            )
        )

        XCTAssertThrowsError(
            try service.createBackup()
        ) { error in
            XCTAssertEqual(
                error as? BackupExportError,
                .invalidEntryAmount(
                    id: entryID,
                    amount: 0
                )
            )
        }
    }

    func testCreateBackup_invalidSettingsDailyGoalThrowsTypedError() throws {
        let service = try makeSUT(
            settings: BackupSettingsV1(
                dailyGoal: 0,
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

        XCTAssertThrowsError(
            try service.createBackup()
        ) { error in
            XCTAssertEqual(
                error as? BackupExportError,
                .invalidSettingsDailyGoal(0)
            )
        }
    }

    func testCreateBackup_doesNotMutateSwiftDataObjects() throws {
        let service = try makeSUT()

        insert(
            WaterEntryEntity(
                amount: 250,
                date: fixedDate,
                drinkTypeRawValue: "water"
            )
        )
        insert(
            WaterGoalEntity(
                dailyGoal: 2_500,
                effectiveDate: fixedDate
            )
        )
        insert(
            HydrationStreakDayEntity(
                dayStartDate: fixedDate,
                createdAt: fixedDate
            )
        )

        let countsBefore = try objectCounts()

        _ = try service.createBackup()

        XCTAssertEqual(
            try objectCounts(),
            countsBefore
        )
    }

    func testCreateBackup_repeatedExportWithFixedClockCreatesIdenticalJSON() throws {
        let service = try makeSUT()

        insert(
            WaterEntryEntity(
                amount: 250,
                date: fixedDate,
                drinkTypeRawValue: "water"
            )
        )

        let firstExport = try service.createBackup()
        let secondExport = try service.createBackup()

        XCTAssertEqual(
            firstExport.data,
            secondExport.data
        )
    }

    // MARK: - Helpers

    private var fixedDate: Date {
        makeDate(
            timeIntervalSince1970: 1_779_876_543.123
        )
    }

    private func makeSUT(
        settings: BackupSettingsV1 = .testDefault,
        date: Date? = nil,
        appVersion: String = "1.2",
        buildNumber: String = "45"
    ) throws -> BackupExportService {
        let schema = Schema([
            WaterEntryEntity.self,
            WaterGoalEntity.self,
            HydrationStreakDayEntity.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        modelContainer = try ModelContainer(
            for: schema,
            configurations: [
                configuration
            ]
        )

        return BackupExportService(
            context: modelContainer.mainContext,
            settingsReader: TestBackupSettingsReader(
                settings: settings
            ),
            appInfoProvider: TestBackupAppInfoProvider(
                appVersion: appVersion,
                buildNumber: buildNumber
            ),
            dateProvider: TestDateProvider(
                now: date ?? fixedDate
            )
        )
    }

    private func decode(
        _ data: Data
    ) throws -> BackupDocumentV1 {
        try BackupJSONCoder.makeDecoder()
            .decode(
                BackupDocumentV1.self,
                from: data
            )
    }

    private func insert<T: PersistentModel>(
        _ entity: T
    ) {
        modelContainer.mainContext.insert(entity)
    }

    private func count<T: PersistentModel>(
        _ modelType: T.Type
    ) throws -> Int {
        try modelContainer.mainContext.fetchCount(
            FetchDescriptor<T>()
        )
    }

    private func objectCounts() throws -> ObjectCounts {
        ObjectCounts(
            entries: try count(WaterEntryEntity.self),
            goals: try count(WaterGoalEntity.self),
            streakDays: try count(HydrationStreakDayEntity.self)
        )
    }

    private func makeDate(
        timeIntervalSince1970: TimeInterval
    ) -> Date {
        Date(
            timeIntervalSince1970: timeIntervalSince1970
        )
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int
    ) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(
            identifier: .gregorian
        )
        components.timeZone = TimeZone(
            secondsFromGMT: 0
        )
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second

        return components.date!
    }
}

private struct TestBackupSettingsReader: BackupSettingsReading {
    let settings: BackupSettingsV1

    func settingsForBackup() -> BackupSettingsV1 {
        settings
    }
}

private struct TestBackupAppInfoProvider: BackupAppInfoProviding {
    let appVersion: String
    let buildNumber: String
}

private struct TestDateProvider: DateProviding {
    let now: Date
}

private struct ObjectCounts: Equatable {
    let entries: Int
    let goals: Int
    let streakDays: Int
}

private extension BackupSettingsV1 {

    static var testDefault: BackupSettingsV1 {
        BackupSettingsV1(
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
    }
}
