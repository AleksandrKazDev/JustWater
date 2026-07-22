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

    @MainActor
    func testMergeBackup_afterSuccessUpdatesDailyGoalAndPreservesOtherSettings() async throws {
        let expectedResult = makeMergeRestoreResult()
        let backupRestoreService = TestBackupRestoreService(
            mergeResult: .success(expectedResult)
        )
        let sut = makeSUT(
            backupRestoreService: backupRestoreService
        )
        let initialState = settingsState(
            of: sut
        )
        var stateBeforeServiceCompletion: SettingsState?
        backupRestoreService.onMergeRestore = { [weak sut] in
            guard let sut else { return }

            stateBeforeServiceCompletion = self.settingsState(
                of: sut
            )
            AppSettingsStorage.dailyGoal = expectedResult.resolvedDailyGoal
        }
        let preparedImport = makePreparedImport()

        let result = try await sut.mergeBackup(
            preparedImport
        )

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(
            backupRestoreService.mergeRestoreCallCount,
            1
        )
        XCTAssertEqual(
            backupRestoreService.lastPreparedImport,
            preparedImport
        )
        XCTAssertEqual(
            stateBeforeServiceCompletion,
            initialState
        )
        XCTAssertEqual(
            settingsState(of: sut),
            initialState.updatingDailyGoal(
                to: expectedResult.resolvedDailyGoal
            )
        )
    }

    @MainActor
    func testMergeBackup_whenServiceThrows_rethrowsAndReportsOnce() async {
        let backupRestoreService = TestBackupRestoreService(
            mergeResult: .failure(TestFailure.expected)
        )
        let errorReporter = TestErrorReporter()
        let sut = makeSUT(
            backupRestoreService: backupRestoreService,
            errorReporter: errorReporter
        )
        let initialState = settingsState(
            of: sut
        )

        do {
            _ = try await sut.mergeBackup(
                makePreparedImport()
            )
            XCTFail("Expected merge restore to fail.")
        } catch {
            XCTAssertEqual(
                error as? TestFailure,
                .expected
            )
        }

        XCTAssertEqual(
            backupRestoreService.mergeRestoreCallCount,
            1
        )
        XCTAssertEqual(
            errorReporter.reports.count,
            1
        )
        XCTAssertEqual(
            errorReporter.reports.first?.context,
            "Failed to merge backup"
        )
        XCTAssertEqual(
            settingsState(of: sut),
            initialState
        )
    }

    @MainActor
    func testMergeBackup_whenCancelled_doesNotReportError() async {
        let backupRestoreService = TestBackupRestoreService(
            mergeResult: .failure(CancellationError())
        )
        let errorReporter = TestErrorReporter()
        let sut = makeSUT(
            backupRestoreService: backupRestoreService,
            errorReporter: errorReporter
        )
        let initialState = settingsState(
            of: sut
        )

        do {
            _ = try await sut.mergeBackup(
                makePreparedImport()
            )
            XCTFail("Expected merge restore to be cancelled.")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }

        XCTAssertTrue(errorReporter.reports.isEmpty)
        XCTAssertEqual(
            settingsState(of: sut),
            initialState
        )
    }

    @MainActor
    func testReplaceBackup_afterSuccessUpdatesDailyGoalAndPreservesOtherSettings() async throws {
        let expectedResult = makeReplaceRestoreResult()
        let backupRestoreService = TestBackupRestoreService(
            replaceResult: .success(expectedResult)
        )
        let sut = makeSUT(
            backupRestoreService: backupRestoreService
        )
        let initialState = settingsState(
            of: sut
        )
        var stateBeforeServiceCompletion: SettingsState?
        backupRestoreService.onReplaceRestore = { [weak sut] in
            guard let sut else { return }

            stateBeforeServiceCompletion = self.settingsState(
                of: sut
            )
        }
        AppSettingsStorage.dailyGoal = 1_800
        let preparedImport = makePreparedImport()

        let result = try await sut.replaceBackup(
            preparedImport
        )

        XCTAssertEqual(result, expectedResult)
        XCTAssertEqual(
            backupRestoreService.replaceRestoreCallCount,
            1
        )
        XCTAssertEqual(
            backupRestoreService.lastReplacePreparedImport,
            preparedImport
        )
        XCTAssertEqual(
            stateBeforeServiceCompletion,
            initialState
        )
        XCTAssertEqual(
            settingsState(of: sut),
            initialState.updatingDailyGoal(
                to: expectedResult.currentDailyGoal
            )
        )
    }

    @MainActor
    func testReplaceBackup_whenServiceThrows_rethrowsAndReportsOnce() async {
        let backupRestoreService = TestBackupRestoreService(
            replaceResult: .failure(TestFailure.expected)
        )
        let errorReporter = TestErrorReporter()
        let sut = makeSUT(
            backupRestoreService: backupRestoreService,
            errorReporter: errorReporter
        )
        let initialState = settingsState(
            of: sut
        )

        do {
            _ = try await sut.replaceBackup(
                makePreparedImport()
            )
            XCTFail("Expected replace restore to fail.")
        } catch {
            XCTAssertEqual(
                error as? TestFailure,
                .expected
            )
        }

        XCTAssertEqual(
            backupRestoreService.replaceRestoreCallCount,
            1
        )
        XCTAssertEqual(
            errorReporter.reports.count,
            1
        )
        XCTAssertEqual(
            errorReporter.reports.first?.context,
            "Failed to replace backup"
        )
        XCTAssertEqual(
            settingsState(of: sut),
            initialState
        )
    }

    @MainActor
    func testReplaceBackup_whenCancelledDoesNotReportErrorOrChangeSettings() async {
        let backupRestoreService = TestBackupRestoreService(
            replaceResult: .failure(CancellationError())
        )
        let errorReporter = TestErrorReporter()
        let sut = makeSUT(
            backupRestoreService: backupRestoreService,
            errorReporter: errorReporter
        )
        let initialState = settingsState(
            of: sut
        )

        do {
            _ = try await sut.replaceBackup(
                makePreparedImport()
            )
            XCTFail("Expected replace restore to be cancelled.")
        } catch {
            XCTAssertTrue(error is CancellationError)
        }

        XCTAssertEqual(
            backupRestoreService.replaceRestoreCallCount,
            1
        )
        XCTAssertTrue(errorReporter.reports.isEmpty)
        XCTAssertEqual(
            settingsState(of: sut),
            initialState
        )
    }

    // MARK: - Concurrent Settings Updates

    func testHealthSync_whenDisableFollowsPendingEnable_latestRequestWins() async {
        AppSettingsStorage.isHealthSyncEnabled = false
        let healthKitService = ControllableHealthKitService()
        let sut = makeSUT(
            healthKitService: healthKitService
        )

        sut.setHealthSyncEnabled(true)
        await fulfillment(
            of: [healthKitService.authorizationStarted],
            timeout: 1
        )

        sut.setHealthSyncEnabled(false)
        await drainMainActor()
        healthKitService.completeAuthorization()
        await drainMainActor()

        XCTAssertFalse(sut.isHealthSyncEnabled)
        XCTAssertFalse(AppSettingsStorage.isHealthSyncEnabled)
    }

    func testReminders_whenDisableFollowsPendingEnable_latestRequestWins() async {
        AppSettingsStorage.areRemindersEnabled = false
        let notificationService = ControllableNotificationService()
        let sut = makeSUT(
            notificationService: notificationService
        )

        sut.setRemindersEnabled(true)
        await fulfillment(
            of: [notificationService.authorizationStatusRequested],
            timeout: 1
        )

        sut.setRemindersEnabled(false)
        await drainMainActor()
        notificationService.completeAuthorizationStatus(with: .authorized)
        await drainMainActor()

        XCTAssertFalse(sut.areRemindersEnabled)
        XCTAssertFalse(AppSettingsStorage.areRemindersEnabled)
        XCTAssertEqual(notificationService.scheduleCallCount, 0)
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
            backupRestoreService: TestBackupRestoreService(
                mergeResult: .failure(TestFailure.unused)
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
            backupRestoreService: TestBackupRestoreService(
                mergeResult: .failure(TestFailure.unused)
            ),
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
            backupRestoreService: TestBackupRestoreService(
                mergeResult: .failure(TestFailure.unused)
            ),
            errorReporter: errorReporter
        )
    }

    @MainActor
    private func makeSUT(
        backupRestoreService: BackupRestoreServicing
    ) -> SettingsViewModel {
        makeSUT(
            backupRestoreService: backupRestoreService,
            errorReporter: TestErrorReporter()
        )
    }

    @MainActor
    private func makeSUT(
        backupRestoreService: BackupRestoreServicing,
        errorReporter: ErrorReporting
    ) -> SettingsViewModel {
        makeSUT(
            backupExportService: TestBackupExportService(
                result: .success(makeBackupResult())
            ),
            backupImportService: TestBackupImportService(
                result: .failure(TestFailure.unused)
            ),
            backupRestoreService: backupRestoreService,
            errorReporter: errorReporter
        )
    }

    @MainActor
    private func makeSUT(
        backupExportService: BackupExportServicing,
        backupImportService: BackupImportServicing,
        backupRestoreService: BackupRestoreServicing,
        errorReporter: ErrorReporting
    ) -> SettingsViewModel {
        makeSUT(
            backupExportService: backupExportService,
            backupImportService: backupImportService,
            backupRestoreService: backupRestoreService,
            errorReporter: errorReporter,
            notificationService: TestNotificationService(),
            healthKitService: TestHealthKitService()
        )
    }

    private func makeSUT(
        backupExportService: BackupExportServicing,
        backupImportService: BackupImportServicing,
        backupRestoreService: BackupRestoreServicing,
        errorReporter: ErrorReporting,
        notificationService: NotificationServicing,
        healthKitService: HealthKitServicing
    ) -> SettingsViewModel {
        SettingsViewModel(
            goalStorageService: TestWaterGoalStorageService(),
            dailyGoalUpdateService: TestDailyGoalUpdateService(),
            backupExportService: backupExportService,
            backupImportService: backupImportService,
            backupRestoreService: backupRestoreService,
            notificationService: notificationService,
            healthKitService: healthKitService,
            errorReporter: errorReporter
        )
    }

    private func makeSUT(
        notificationService: NotificationServicing
    ) -> SettingsViewModel {
        makeSUT(
            backupExportService: TestBackupExportService(
                result: .success(makeBackupResult())
            ),
            backupImportService: TestBackupImportService(
                result: .failure(TestFailure.unused)
            ),
            backupRestoreService: TestBackupRestoreService(
                mergeResult: .failure(TestFailure.unused)
            ),
            errorReporter: TestErrorReporter(),
            notificationService: notificationService,
            healthKitService: TestHealthKitService()
        )
    }

    private func makeSUT(
        healthKitService: HealthKitServicing
    ) -> SettingsViewModel {
        makeSUT(
            backupExportService: TestBackupExportService(
                result: .success(makeBackupResult())
            ),
            backupImportService: TestBackupImportService(
                result: .failure(TestFailure.unused)
            ),
            backupRestoreService: TestBackupRestoreService(
                mergeResult: .failure(TestFailure.unused)
            ),
            errorReporter: TestErrorReporter(),
            notificationService: TestNotificationService(),
            healthKitService: healthKitService
        )
    }

    private func drainMainActor() async {
        for _ in 0..<10 {
            await Task.yield()
        }
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

    private func makeMergeRestoreResult() -> MergeRestoreResult {
        MergeRestoreResult(
            waterEntries: MergeRestoreCounts(
                inserted: 1,
                unchanged: 2,
                conflicts: 3
            ),
            goalHistory: MergeRestoreCounts(
                inserted: 4,
                unchanged: 5,
                conflicts: 6
            ),
            streakDays: MergeRestoreCounts(
                inserted: 7,
                unchanged: 8,
                conflicts: 9
            ),
            resolvedDailyGoal: 2_500
        )
    }

    private func makeReplaceRestoreResult() -> ReplaceRestoreResult {
        ReplaceRestoreResult(
            restoredEntriesCount: 1,
            restoredGoalsCount: 2,
            restoredStreakDaysCount: 3,
            currentDailyGoal: 2_700
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
private final class TestBackupRestoreService: BackupRestoreServicing {

    private let mergeResult: Result<MergeRestoreResult, Error>
    private let replaceResult: Result<ReplaceRestoreResult, Error>
    private(set) var mergeRestoreCallCount = 0
    private(set) var replaceRestoreCallCount = 0
    private(set) var lastPreparedImport: PreparedBackupImport?
    private(set) var lastReplacePreparedImport: PreparedBackupImport?
    var onMergeRestore: (() -> Void)?
    var onReplaceRestore: (() -> Void)?

    init(
        mergeResult: Result<MergeRestoreResult, Error> = .failure(TestFailure.unused),
        replaceResult: Result<ReplaceRestoreResult, Error> = .failure(TestFailure.unused)
    ) {
        self.mergeResult = mergeResult
        self.replaceResult = replaceResult
    }

    func mergeRestore(
        _ preparedImport: PreparedBackupImport
    ) async throws -> MergeRestoreResult {
        mergeRestoreCallCount += 1
        lastPreparedImport = preparedImport
        onMergeRestore?()

        return try mergeResult.get()
    }

    func replaceRestore(
        _ preparedImport: PreparedBackupImport
    ) async throws -> ReplaceRestoreResult {
        replaceRestoreCallCount += 1
        lastReplacePreparedImport = preparedImport
        onReplaceRestore?()

        return try replaceResult.get()
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

@MainActor
private final class ControllableNotificationService: NotificationServicing {

    let authorizationStatusRequested = XCTestExpectation(
        description: "Notification authorization status requested"
    )
    private var authorizationStatusContinuation: CheckedContinuation<UNAuthorizationStatus, Never>?
    private(set) var scheduleCallCount = 0

    func requestAuthorization() async -> Bool {
        true
    }

    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        authorizationStatusRequested.fulfill()

        return await withCheckedContinuation { continuation in
            authorizationStatusContinuation = continuation
        }
    }

    func completeAuthorizationStatus(
        with status: UNAuthorizationStatus
    ) {
        authorizationStatusContinuation?.resume(returning: status)
        authorizationStatusContinuation = nil
    }

    func openAppNotificationSettings() {}

    func scheduleHydrationReminders(
        startHour: Int,
        endHour: Int,
        frequency: ReminderFrequency
    ) async {
        scheduleCallCount += 1
    }

    func cancelHydrationReminders() {}
}

@MainActor
private final class ControllableHealthKitService: HealthKitServicing {

    nonisolated var isHealthDataAvailable: Bool {
        true
    }

    let authorizationStarted = XCTestExpectation(
        description: "Health authorization started"
    )
    private var authorizationContinuation: CheckedContinuation<Void, Error>?

    func requestAuthorization() async throws {
        authorizationStarted.fulfill()

        try await withCheckedThrowingContinuation { continuation in
            authorizationContinuation = continuation
        }
    }

    func completeAuthorization() {
        authorizationContinuation?.resume()
        authorizationContinuation = nil
    }

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

    func updatingDailyGoal(
        to dailyGoal: Int
    ) -> SettingsState {
        SettingsState(
            dailyGoal: dailyGoal,
            isHapticsEnabled: isHapticsEnabled,
            appearanceMode: appearanceMode,
            measurementUnit: measurementUnit,
            areRemindersEnabled: areRemindersEnabled,
            reminderStartHour: reminderStartHour,
            reminderEndHour: reminderEndHour,
            reminderFrequency: reminderFrequency,
            notificationAuthorizationStatus: notificationAuthorizationStatus,
            isHealthSyncEnabled: isHealthSyncEnabled
        )
    }
}
