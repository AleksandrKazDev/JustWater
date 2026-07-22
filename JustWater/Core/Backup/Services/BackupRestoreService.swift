//
//  BackupRestoreService.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation
import SwiftData

protocol BackupRestoreServicing: Sendable {
    func mergeRestore(
        _ preparedImport: PreparedBackupImport
    ) async throws -> MergeRestoreResult

    func replaceRestore(
        _ preparedImport: PreparedBackupImport
    ) async throws -> ReplaceRestoreResult
}

actor BackupRestoreService: BackupRestoreServicing {

    // MARK: - Properties

    private let modelContainer: ModelContainer
    private let calendar: Calendar
    private let validator: BackupDocumentValidator

    // MARK: - Initializer

    init(
        modelContainer: ModelContainer,
        calendar: Calendar = .current
    ) {
        self.modelContainer = modelContainer
        self.calendar = calendar
        self.validator = BackupDocumentValidator(
            calendar: calendar
        )
    }

    // MARK: - Public Methods

    func mergeRestore(
        _ preparedImport: PreparedBackupImport
    ) async throws -> MergeRestoreResult {
        try Task.checkCancellation()

        let document = try decodeAndValidate(
            preparedImport.data
        )

        try Task.checkCancellation()

        let context = ModelContext(modelContainer)
        var result: MergeRestoreResult?

        do {
            try context.transaction {
                try Task.checkCancellation()

                let existingData = try fetchExistingData(
                    context: context
                )

                result = try merge(
                    document: document,
                    existingData: existingData,
                    context: context
                )
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as BackupRestoreError {
            throw error
        } catch {
            throw BackupRestoreError.persistenceFailed
        }

        guard let result else {
            throw BackupRestoreError.persistenceFailed
        }

        if AppSettingsStorage.dailyGoal != result.resolvedDailyGoal {
            AppSettingsStorage.dailyGoal = result.resolvedDailyGoal
        }

        return result
    }

    func replaceRestore(
        _ preparedImport: PreparedBackupImport
    ) async throws -> ReplaceRestoreResult {
        try Task.checkCancellation()

        let document = try decodeAndValidate(
            preparedImport.data
        )

        try Task.checkCancellation()

        let context = ModelContext(modelContainer)
        var result: ReplaceRestoreResult?

        do {
            try context.transaction {
                try Task.checkCancellation()

                let existingData = try fetchExistingData(
                    context: context
                )

                try Task.checkCancellation()

                result = try replace(
                    document: document,
                    existingData: existingData,
                    context: context
                )
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as BackupRestoreError {
            throw error
        } catch {
            throw BackupRestoreError.persistenceFailed
        }

        guard let result else {
            throw BackupRestoreError.persistenceFailed
        }

        if AppSettingsStorage.dailyGoal != result.currentDailyGoal {
            AppSettingsStorage.dailyGoal = result.currentDailyGoal
        }

        return result
    }

    // MARK: - Decoding

    private func decodeAndValidate(
        _ data: Data
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
            throw BackupRestoreError.invalidPreparedBackup
        }

        do {
            try validator.validate(document)
        } catch {
            throw BackupRestoreError.invalidPreparedBackup
        }

        return document
    }

    // MARK: - Fetching

    private func fetchExistingData(
        context: ModelContext
    ) throws -> ExistingRestoreData {
        do {
            return ExistingRestoreData(
                entries: try context.fetch(
                    FetchDescriptor<WaterEntryEntity>()
                ),
                goals: try context.fetch(
                    FetchDescriptor<WaterGoalEntity>()
                ),
                streakDays: try context.fetch(
                    FetchDescriptor<HydrationStreakDayEntity>()
                )
            )
        } catch {
            throw BackupRestoreError.cannotReadCurrentData
        }
    }

    // MARK: - Merge

    private func merge(
        document: BackupDocumentV1,
        existingData: ExistingRestoreData,
        context: ModelContext
    ) throws -> MergeRestoreResult {
        var entryIndex = Dictionary(
            uniqueKeysWithValues: existingData.entries.map {
                ($0.id, $0)
            }
        )
        var goalIDIndex = Dictionary(
            uniqueKeysWithValues: existingData.goals.map {
                ($0.id, $0)
            }
        )
        var goalDateIndex: [Date: WaterGoalEntity] = [:]
        var streakDateIndex: [Date: HydrationStreakDayEntity] = [:]

        for goal in existingData.goals {
            goalDateIndex[normalizedDay(goal.effectiveDate)] = goal
        }

        for streakDay in existingData.streakDays {
            streakDateIndex[normalizedDay(streakDay.dayStartDate)] = streakDay
        }

        let entryCounts = try mergeEntries(
            document.entries,
            index: &entryIndex,
            context: context
        )
        let goalCounts = try mergeGoals(
            document.goalHistory,
            idIndex: &goalIDIndex,
            dateIndex: &goalDateIndex,
            context: context
        )
        let streakCounts = try mergeStreakDays(
            document.streakDays,
            dateIndex: &streakDateIndex,
            context: context
        )

        try Task.checkCancellation()

        let resolvedDailyGoal = goalDateIndex
            .max { lhs, rhs in
                lhs.key < rhs.key
            }?
            .value
            .dailyGoal
        ?? document.settings.dailyGoal

        return MergeRestoreResult(
            waterEntries: entryCounts,
            goalHistory: goalCounts,
            streakDays: streakCounts,
            resolvedDailyGoal: resolvedDailyGoal
        )
    }

    private func mergeEntries(
        _ entries: [BackupWaterEntryV1],
        index: inout [UUID: WaterEntryEntity],
        context: ModelContext
    ) throws -> MergeRestoreCounts {
        var inserted = 0
        var unchanged = 0
        var conflicts = 0

        for (offset, entry) in entries.enumerated() {
            try checkCancellationIfNeeded(offset)

            if let existing = index[entry.id] {
                if existing.amount == entry.amount,
                   existing.date == entry.date,
                   existing.drinkTypeRawValue == entry.drinkTypeRawValue {
                    unchanged += 1
                } else {
                    conflicts += 1
                }

                continue
            }

            let entity = WaterEntryEntity(
                id: entry.id,
                amount: entry.amount,
                date: entry.date,
                drinkTypeRawValue: entry.drinkTypeRawValue
            )
            context.insert(entity)
            index[entry.id] = entity
            inserted += 1
        }

        return MergeRestoreCounts(
            inserted: inserted,
            unchanged: unchanged,
            conflicts: conflicts
        )
    }

    private func mergeGoals(
        _ goals: [BackupWaterGoalV1],
        idIndex: inout [UUID: WaterGoalEntity],
        dateIndex: inout [Date: WaterGoalEntity],
        context: ModelContext
    ) throws -> MergeRestoreCounts {
        var inserted = 0
        var unchanged = 0
        var conflicts = 0

        for (offset, goal) in goals.enumerated() {
            try checkCancellationIfNeeded(offset)

            let effectiveDate = normalizedDay(
                goal.effectiveDate
            )

            if let existing = idIndex[goal.id] {
                if existing.dailyGoal == goal.dailyGoal,
                   normalizedDay(existing.effectiveDate) == effectiveDate {
                    unchanged += 1
                } else {
                    conflicts += 1
                }

                continue
            }

            if dateIndex[effectiveDate] != nil {
                conflicts += 1
                continue
            }

            let entity = WaterGoalEntity(
                id: goal.id,
                dailyGoal: goal.dailyGoal,
                effectiveDate: effectiveDate
            )
            context.insert(entity)
            idIndex[goal.id] = entity
            dateIndex[effectiveDate] = entity
            inserted += 1
        }

        return MergeRestoreCounts(
            inserted: inserted,
            unchanged: unchanged,
            conflicts: conflicts
        )
    }

    private func mergeStreakDays(
        _ streakDays: [BackupStreakDayV1],
        dateIndex: inout [Date: HydrationStreakDayEntity],
        context: ModelContext
    ) throws -> MergeRestoreCounts {
        var inserted = 0
        var unchanged = 0
        var conflicts = 0

        for (offset, streakDay) in streakDays.enumerated() {
            try checkCancellationIfNeeded(offset)

            let dayStartDate = normalizedDay(
                streakDay.dayStartDate
            )

            if let existing = dateIndex[dayStartDate] {
                if normalizedDay(existing.dayStartDate) == dayStartDate,
                   existing.createdAt == streakDay.createdAt {
                    unchanged += 1
                } else {
                    conflicts += 1
                }

                continue
            }

            let entity = HydrationStreakDayEntity(
                dayStartDate: dayStartDate,
                createdAt: streakDay.createdAt
            )
            context.insert(entity)
            dateIndex[dayStartDate] = entity
            inserted += 1
        }

        return MergeRestoreCounts(
            inserted: inserted,
            unchanged: unchanged,
            conflicts: conflicts
        )
    }

    // MARK: - Replace

    private func replace(
        document: BackupDocumentV1,
        existingData: ExistingRestoreData,
        context: ModelContext
    ) throws -> ReplaceRestoreResult {
        try deleteExistingData(
            existingData,
            context: context
        )
        try insertReplacementData(
            document,
            context: context
        )

        try Task.checkCancellation()

        let currentDailyGoal = document.goalHistory
            .max { lhs, rhs in
                normalizedDay(lhs.effectiveDate)
                < normalizedDay(rhs.effectiveDate)
            }?
            .dailyGoal
        ?? document.settings.dailyGoal

        return ReplaceRestoreResult(
            restoredEntriesCount: document.entries.count,
            restoredGoalsCount: document.goalHistory.count,
            restoredStreakDaysCount: document.streakDays.count,
            currentDailyGoal: currentDailyGoal
        )
    }

    private func deleteExistingData(
        _ existingData: ExistingRestoreData,
        context: ModelContext
    ) throws {
        for (offset, entry) in existingData.entries.enumerated() {
            try checkCancellationIfNeeded(offset)
            context.delete(entry)
        }

        for (offset, goal) in existingData.goals.enumerated() {
            try checkCancellationIfNeeded(offset)
            context.delete(goal)
        }

        for (offset, streakDay) in existingData.streakDays.enumerated() {
            try checkCancellationIfNeeded(offset)
            context.delete(streakDay)
        }
    }

    private func insertReplacementData(
        _ document: BackupDocumentV1,
        context: ModelContext
    ) throws {
        for (offset, entry) in document.entries.enumerated() {
            try checkCancellationIfNeeded(offset)
            context.insert(
                WaterEntryEntity(
                    id: entry.id,
                    amount: entry.amount,
                    date: entry.date,
                    drinkTypeRawValue: entry.drinkTypeRawValue
                )
            )
        }

        for (offset, goal) in document.goalHistory.enumerated() {
            try checkCancellationIfNeeded(offset)
            context.insert(
                WaterGoalEntity(
                    id: goal.id,
                    dailyGoal: goal.dailyGoal,
                    effectiveDate: normalizedDay(goal.effectiveDate)
                )
            )
        }

        for (offset, streakDay) in document.streakDays.enumerated() {
            try checkCancellationIfNeeded(offset)
            context.insert(
                HydrationStreakDayEntity(
                    dayStartDate: normalizedDay(streakDay.dayStartDate),
                    createdAt: streakDay.createdAt
                )
            )
        }
    }

    // MARK: - Helpers

    private func normalizedDay(
        _ date: Date
    ) -> Date {
        calendar.startOfDay(
            for: date
        )
    }

    private func checkCancellationIfNeeded(
        _ offset: Int
    ) throws {
        if offset.isMultiple(of: 256) {
            try Task.checkCancellation()
        }
    }

}

private struct ExistingRestoreData {
    let entries: [WaterEntryEntity]
    let goals: [WaterGoalEntity]
    let streakDays: [HydrationStreakDayEntity]
}
