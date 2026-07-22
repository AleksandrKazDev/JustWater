//
//  SwiftDataTransactionUniquenessTests.swift
//  JustWaterTests
//
//  Created by сонный on 22.07.2026.
//

import Foundation
import SwiftData
import XCTest
@testable import JustWater

@MainActor
final class SwiftDataTransactionUniquenessTests: XCTestCase {

    func testTransaction_deleteThenInsertWaterEntryWithSameUniqueID() throws {
        let container = try makeContainer()
        let id = UUID()
        let originalDate = Date(timeIntervalSince1970: 1_700_000_000)
        let replacementDate = originalDate.addingTimeInterval(60)
        try insert(
            WaterEntryEntity(
                id: id,
                amount: 250,
                date: originalDate,
                drinkTypeRawValue: DrinkType.water.rawValue
            ),
            into: container
        )
        let context = ModelContext(container)

        try context.transaction {
            let existingEntries = try context.fetch(
                FetchDescriptor<WaterEntryEntity>()
            )
            existingEntries.forEach(context.delete)
            context.insert(
                WaterEntryEntity(
                    id: id,
                    amount: 500,
                    date: replacementDate,
                    drinkTypeRawValue: DrinkType.tea.rawValue
                )
            )
        }

        let entries = try fetch(WaterEntryEntity.self, from: container)
        let entry = try XCTUnwrap(entries.first)
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entry.id, id)
        XCTAssertEqual(entry.amount, 500)
        XCTAssertEqual(entry.date, replacementDate)
        XCTAssertEqual(entry.drinkTypeRawValue, DrinkType.tea.rawValue)
    }

    func testTransaction_deleteThenInsertWaterGoalWithSameUniqueID() throws {
        let container = try makeContainer()
        let id = UUID()
        let originalDate = Date(timeIntervalSince1970: 1_700_000_000)
        let replacementDate = originalDate.addingTimeInterval(86_400)
        try insert(
            WaterGoalEntity(
                id: id,
                dailyGoal: 2_000,
                effectiveDate: originalDate
            ),
            into: container
        )
        let context = ModelContext(container)

        try context.transaction {
            let existingGoals = try context.fetch(
                FetchDescriptor<WaterGoalEntity>()
            )
            existingGoals.forEach(context.delete)
            context.insert(
                WaterGoalEntity(
                    id: id,
                    dailyGoal: 2_500,
                    effectiveDate: replacementDate
                )
            )
        }

        let goals = try fetch(WaterGoalEntity.self, from: container)
        let goal = try XCTUnwrap(goals.first)
        XCTAssertEqual(goals.count, 1)
        XCTAssertEqual(goal.id, id)
        XCTAssertEqual(goal.dailyGoal, 2_500)
        XCTAssertEqual(goal.effectiveDate, replacementDate)
    }

    func testTransaction_deleteThenInsertStreakDayWithSameUniqueDate() throws {
        let container = try makeContainer()
        let dayStartDate = Date(timeIntervalSince1970: 1_700_000_000)
        let originalCreatedAt = dayStartDate.addingTimeInterval(60)
        let replacementCreatedAt = dayStartDate.addingTimeInterval(120)
        try insert(
            HydrationStreakDayEntity(
                dayStartDate: dayStartDate,
                createdAt: originalCreatedAt
            ),
            into: container
        )
        let context = ModelContext(container)

        try context.transaction {
            let existingStreakDays = try context.fetch(
                FetchDescriptor<HydrationStreakDayEntity>()
            )
            existingStreakDays.forEach(context.delete)
            context.insert(
                HydrationStreakDayEntity(
                    dayStartDate: dayStartDate,
                    createdAt: replacementCreatedAt
                )
            )
        }

        let streakDays = try fetch(
            HydrationStreakDayEntity.self,
            from: container
        )
        let streakDay = try XCTUnwrap(streakDays.first)
        XCTAssertEqual(streakDays.count, 1)
        XCTAssertEqual(streakDay.dayStartDate, dayStartDate)
        XCTAssertEqual(streakDay.createdAt, replacementCreatedAt)
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

    private func insert<T: PersistentModel>(
        _ entity: T,
        into container: ModelContainer
    ) throws {
        let context = ModelContext(container)
        context.insert(entity)
        try context.save()
    }

    private func fetch<T: PersistentModel>(
        _ modelType: T.Type,
        from container: ModelContainer
    ) throws -> [T] {
        let context = ModelContext(container)
        return try context.fetch(FetchDescriptor<T>())
    }
}
