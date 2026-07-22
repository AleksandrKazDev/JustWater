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

    // MARK: - Helpers

    @MainActor
    private func makeSUT(
        backupExportService: BackupExportServicing
    ) -> SettingsViewModel {
        makeSUT(
            backupExportService: backupExportService,
            errorReporter: TestErrorReporter()
        )
    }

    @MainActor
    private func makeSUT(
        backupExportService: BackupExportServicing,
        errorReporter: ErrorReporting
    ) -> SettingsViewModel {
        SettingsViewModel(
            goalStorageService: TestWaterGoalStorageService(),
            dailyGoalUpdateService: TestDailyGoalUpdateService(),
            backupExportService: backupExportService,
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
}

private enum TestFailure: Error, Equatable {
    case expected
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
