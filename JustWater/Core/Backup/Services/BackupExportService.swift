//
//  BackupExportService.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation
import SwiftData

@MainActor
protocol BackupExportServicing {
    func createBackup() throws -> BackupExportResult
}

@MainActor
final class BackupExportService: BackupExportServicing {

    // MARK: - Dependencies

    private let context: ModelContext
    private let settingsReader: BackupSettingsReading
    private let appInfoProvider: BackupAppInfoProviding
    private let dateProvider: DateProviding

    // MARK: - Initializer

    init(
        context: ModelContext,
        settingsReader: BackupSettingsReading = AppSettingsBackupReader(),
        appInfoProvider: BackupAppInfoProviding = BundleBackupAppInfoProvider(),
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        self.context = context
        self.settingsReader = settingsReader
        self.appInfoProvider = appInfoProvider
        self.dateProvider = dateProvider
    }

    // MARK: - Public Methods

    func createBackup() throws -> BackupExportResult {
        let createdAt = dateProvider.now
        let document = try makeDocument(
            createdAt: createdAt
        )

        let data: Data

        do {
            data = try BackupJSONCoder.makeEncoder()
                .encode(document)
        } catch {
            throw BackupExportError.encodingFailed
        }

        return BackupExportResult(
            data: data,
            suggestedFileName: BackupFileNameFormatter.fileName(
                createdAt: createdAt
            ),
            createdAt: createdAt,
            entriesCount: document.entries.count,
            goalRecordsCount: document.goalHistory.count,
            streakDaysCount: document.streakDays.count
        )
    }

    // MARK: - Private Methods

    private func makeDocument(
        createdAt: Date
    ) throws -> BackupDocumentV1 {
        do {
            let entries = try fetchEntries()
            let goalHistory = try fetchGoalHistory()
            let streakDays = try fetchStreakDays()
            let settings = settingsReader.settingsForBackup()

            try validate(
                createdAt: createdAt,
                entries: entries,
                goalHistory: goalHistory,
                streakDays: streakDays,
                settings: settings
            )

            return BackupDocumentV1(
                appVersion: appInfoProvider.appVersion,
                buildNumber: appInfoProvider.buildNumber,
                createdAt: createdAt,
                entries: entries,
                goalHistory: goalHistory,
                streakDays: streakDays,
                settings: settings
            )
        } catch let error as BackupExportError {
            throw error
        } catch {
            throw BackupExportError.readFailed
        }
    }

    private func fetchEntries() throws -> [BackupWaterEntryV1] {
        let descriptor = FetchDescriptor<WaterEntryEntity>()

        return try context.fetch(descriptor)
            .map {
                BackupWaterEntryV1(
                    id: $0.id,
                    amount: $0.amount,
                    date: $0.date,
                    drinkTypeRawValue: $0.drinkTypeRawValue
                )
            }
            .sorted {
                if $0.date != $1.date {
                    return $0.date < $1.date
                }

                return $0.id.uuidString < $1.id.uuidString
            }
    }

    private func fetchGoalHistory() throws -> [BackupWaterGoalV1] {
        let descriptor = FetchDescriptor<WaterGoalEntity>()

        return try context.fetch(descriptor)
            .map {
                BackupWaterGoalV1(
                    id: $0.id,
                    dailyGoal: $0.dailyGoal,
                    effectiveDate: $0.effectiveDate
                )
            }
            .sorted {
                if $0.effectiveDate != $1.effectiveDate {
                    return $0.effectiveDate < $1.effectiveDate
                }

                return $0.id.uuidString < $1.id.uuidString
            }
    }

    private func fetchStreakDays() throws -> [BackupStreakDayV1] {
        let descriptor = FetchDescriptor<HydrationStreakDayEntity>()

        return try context.fetch(descriptor)
            .map {
                BackupStreakDayV1(
                    dayStartDate: $0.dayStartDate,
                    createdAt: $0.createdAt
                )
            }
            .sorted {
                $0.dayStartDate < $1.dayStartDate
            }
    }

    private func validate(
        createdAt: Date,
        entries: [BackupWaterEntryV1],
        goalHistory: [BackupWaterGoalV1],
        streakDays: [BackupStreakDayV1],
        settings: BackupSettingsV1
    ) throws {
        try validate(date: createdAt)

        for entry in entries {
            guard entry.amount > 0 else {
                throw BackupExportError.invalidEntryAmount(
                    id: entry.id,
                    amount: entry.amount
                )
            }

            try validate(date: entry.date)
        }

        for goal in goalHistory {
            guard goal.dailyGoal > 0 else {
                throw BackupExportError.invalidGoalAmount(
                    id: goal.id,
                    dailyGoal: goal.dailyGoal
                )
            }

            try validate(date: goal.effectiveDate)
        }

        for streakDay in streakDays {
            try validate(date: streakDay.dayStartDate)
            try validate(date: streakDay.createdAt)
        }

        guard settings.dailyGoal > 0 else {
            throw BackupExportError.invalidSettingsDailyGoal(
                settings.dailyGoal
            )
        }

        try validateReminderHour(settings.reminderStartHour)
        try validateReminderHour(settings.reminderEndHour)
    }

    private func validate(
        date: Date
    ) throws {
        guard date.timeIntervalSinceReferenceDate.isFinite else {
            throw BackupExportError.invalidDate
        }
    }

    private func validateReminderHour(
        _ hour: Int
    ) throws {
        guard (0...23).contains(hour) else {
            throw BackupExportError.invalidReminderHour(hour)
        }
    }
}
