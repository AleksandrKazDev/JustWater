//
//  SettingsViewModelBackupTests.swift
//  JustWaterTests
//
//  Created by сонный on 22.07.2026.
//

import Foundation
import UserNotifications
import XCTest
@testable import JustWater

@MainActor
final class SettingsViewModelBackupTests: XCTestCase {

    override func setUp() {
        super.setUp()
        AppSettingsStorageTestSupport.setUpIsolatedDefaults()
    }

    override func tearDown() {
        AppSettingsStorageTestSupport.tearDownIsolatedDefaults()
        super.tearDown()
    }

    @MainActor
    func testCreateBackup_delegatesToServiceAndReturnsResult() throws {
        let expectedResult = makeBackupResult()
        let backupExportService = TestBackupExportService(
            result: .success(expectedResult)
        )
        let sut = makeSUT(
            backupExportService: backupExportService
        )

        let result = try sut.createBackup()

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(
            backupExportService.createBackupCallCount,
            1
        )
    }

    @MainActor
    func testCreateBackup_whenServiceThrows_rethrowsAndReportsError() {
        let backupExportService = TestBackupExportService(
            result: .failure(TestFailure.expected)
        )
        let errorReporter = TestErrorReporter()
        let sut = makeSUT(
            backupExportService: backupExportService,
            errorReporter: errorReporter
        )

        XCTAssertThrowsError(
            try sut.createBackup()
        ) { error in
            XCTAssertEqual(
                error as? TestFailure,
                .expected
            )
        }
        XCTAssertEqual(
            backupExportService.createBackupCallCount,
            1
        )
        XCTAssertEqual(
            errorReporter.reports.count,
            1
        )
        XCTAssertEqual(
            errorReporter.reports.first?.context,
            "Failed to create backup"
        )
    }

    @MainActor
    func testPrepareBackupImport_delegatesOnceReturnsResultAndPreservesSettings() async throws {
        let expectedResult = makePreparedImport()
        let backupImportService = TestBackupImportService(
            result: .success(expectedResult)
        )
        let sut = makeSUT(
            backupImportService: backupImportService
        )
        let initialState = settingsState(
            of: sut
        )
        let url = URL(
            fileURLWithPath: "/tmp/JustWaterBackup.json"
        )

        let result = try await sut.prepareBackupImport(
            from: url
        )

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(
            backupImportService.prepareImportCallCount,
            1
        )
        XCTAssertEqual(
            backupImportService.lastURL,
            url
        )
        XCTAssertEqual(
            settingsState(of: sut),
            initialState
        )
    }

    @MainActor
    func testPrepareBackupImport_whenServiceThrows_rethrowsAndReportsOnce() async {
        let backupImportService = TestBackupImportService(
            result: .failure(TestFailure.expected)
        )
        let errorReporter = TestErrorReporter()
        let sut = makeSUT(
            backupImportService: backupImportService,
            errorReporter: errorReporter
        )

        do {
            _ = try await sut.prepareBackupImport(
                from: URL(fileURLWithPath: "/tmp/backup.json")
            )
            XCTFail("Expected import preparation to fail.")
        } catch {
            XCTAssertEqual(
                error as? TestFailure,
                .expected
            )
        }

        XCTAssertEqual(
            backupImportService.prepareImportCallCount,
            1
        )
        XCTAssertEqual(
            errorReporter.reports.count,
            1
        )
        XCTAssertEqual(
            errorReporter.reports.first?.context,
            "Failed to prepare backup import"
        )
    }

    @MainActor
    func testPrepareBackupImport_whenCancelled_doesNotReportError() async {
        let backupImportService = TestBackupImportService(
            result: .failure(CancellationError())
        )
        let errorReporter = TestErrorReporter()
        let sut = makeSUT(
            backupImportService: backupImportService,
            errorReporter: errorReporter
        )

        do {
            _ = try await sut.prepareBackupImport(
                from: URL(fileURLWithPath: "/tmp/backup.json")
            )
            XCTFail("Expected import preparation to be cancelled.")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }

        XCTAssertTrue(errorReporter.reports.isEmpty)
    }

    // MARK: - Helpers

    @MainActor
    private func makeSUT(
        backupExportService: BackupExportServicing
    ) -> SettingsViewModel {
        makeSUT(
            backupExportService: backupExportService,
            backupImportService: TestBackupImportService(
                result: .failure(TestFailure.unused)
            ),
            errorReporter: TestErrorReporter()
        )
    }

    @MainActor
    private func makeSUT(
        backupImportService: BackupImportServicing,
        errorReporter: ErrorReporting
    ) -> SettingsViewModel {
        makeSUT(
            backupExportService: TestBackupExportService(
                result: .success(makeBackupResult())
            ),
            backupImportService: backupImportService,
            errorReporter: errorReporter
        )
    }

    @MainActor
    private func makeSUT(
        backupImportService: BackupImportServicing
    ) -> SettingsViewModel {
        makeSUT(
            backupImportService: backupImportService,
            errorReporter: TestErrorReporter()
        )
    }

    @MainActor
    private func makeSUT(
        backupExportService: BackupExportServicing,
        errorReporter: ErrorReporting
    ) -> SettingsViewModel {
        makeSUT(
            backupExportService: backupExportService,
            backupImportService: TestBackupImportService(
                result: .failure(TestFailure.unused)
            ),
            errorReporter: errorReporter
        )
    }

    @MainActor
    private func makeSUT(
        backupExportService: BackupExportServicing,
        backupImportService: BackupImportServicing,
        errorReporter: ErrorReporting
    ) -> SettingsViewModel {
        SettingsViewModel(
            goalStorageService: TestWaterGoalStorageService(),
            dailyGoalUpdateService: TestDailyGoalUpdateService(),
            backupExportService: backupExportService,
            backupImportService: backupImportService,
            notificationService: TestNotificationService(),
            healthKitService: TestHealthKitService(),
            errorReporter: errorReporter
        )
    }

    private func makeBackupResult() -> BackupExportResult {
        BackupExportResult(
            data: Data("{}".utf8),
            suggestedFileName: "JustWaterBackup.json",
            createdAt: Date(timeIntervalSince1970: 1_700_000_000),
            entriesCount: 1,
            goalRecordsCount: 2,
            streakDaysCount: 3
        )
    }

    private func makePreparedImport() -> PreparedBackupImport {
        let data = Data("{}".utf8)

        return PreparedBackupImport(
            preview: BackupImportPreview(
                fileName: "JustWaterBackup.json",
                createdAt: Date(timeIntervalSince1970: 1_700_000_000),
                appVersion: "1.2",
                buildNumber: "45",
                waterEntryCount: 1,
                goalHistoryCount: 2,
                streakDayCount: 3,
                fileSize: data.count
            ),
            data: data
        )
    }

    private func settingsState(
        of viewModel: SettingsViewModel
    ) -> SettingsState {
        SettingsState(
            dailyGoal: viewModel.dailyGoal,
            isHapticsEnabled: viewModel.isHapticsEnabled,
            appearanceMode: viewModel.appearanceMode,
            measurementUnit: viewModel.measurementUnit,
            areRemindersEnabled: viewModel.areRemindersEnabled,
            reminderStartHour: viewModel.reminderStartHour,
            reminderEndHour: viewModel.reminderEndHour,
            reminderFrequency: viewModel.reminderFrequency,
            notificationAuthorizationStatus: viewModel.notificationAuthorizationStatus,
            isHealthSyncEnabled: viewModel.isHealthSyncEnabled
        )
    }
}

private enum TestFailure: Error, Equatable {
    case expected
    case unused
}

@MainActor
private final class TestBackupExportService: BackupExportServicing {

    private let result: Result<BackupExportResult, Error>
    private(set) var createBackupCallCount = 0

    init(
        result: Result<BackupExportResult, Error>
    ) {
        self.result = result
    }

    func createBackup() throws -> BackupExportResult {
        createBackupCallCount += 1

        return try result.get()
    }
}

@MainActor
private final class TestBackupImportService: BackupImportServicing {

    private let result: Result<PreparedBackupImport, Error>
    private(set) var prepareImportCallCount = 0
    private(set) var lastURL: URL?

    init(
        result: Result<PreparedBackupImport, Error>
    ) {
        self.result = result
    }

    func prepareImport(
        from url: URL
    ) async throws -> PreparedBackupImport {
        prepareImportCallCount += 1
        lastURL = url

        return try result.get()
    }
}

@MainActor
private final class TestDailyGoalUpdateService: DailyGoalUpdating {

    func updateDailyGoal(
        _ goal: Int
    ) throws {}
}

@MainActor
private final class TestNotificationService: NotificationServicing {

    func requestAuthorization() async -> Bool {
        true
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        .authorized
    }

    func openAppNotificationSettings() {}

    func scheduleHydrationReminders(
        startHour: Int,
        endHour: Int,
        frequency: ReminderFrequency
    ) async {}

    func cancelHydrationReminders() {}
}

private final class TestHealthKitService: HealthKitServicing {

    var isHealthDataAvailable: Bool {
        true
    }

    func requestAuthorization() async throws {}

    func saveWater(
        amountInMilliliters: Int,
        date: Date,
        entryID: UUID
    ) async throws {}

    func deleteWaterSample(
        entryID: UUID
    ) async throws {}
}

private struct SettingsState: Equatable {
    let dailyGoal: Int
    let isHapticsEnabled: Bool
    let appearanceMode: AppAppearanceMode
    let measurementUnit: MeasurementUnit
    let areRemindersEnabled: Bool
    let reminderStartHour: Int
    let reminderEndHour: Int
    let reminderFrequency: ReminderFrequency
    let notificationAuthorizationStatus: UNAuthorizationStatus
    let isHealthSyncEnabled: Bool
}
