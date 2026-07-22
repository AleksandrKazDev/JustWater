//
//  GoalAchievementServiceTests.swift
//  JustWaterTests
//
//  Created by сонный on 22.07.2026.
//

import XCTest
@testable import JustWater

final class GoalAchievementServiceTests: XCTestCase {

    // MARK: - Tests

    func testShouldShowCongratulations_whenTodayCrossesGoal_returnsTrue() {
        let sut = makeSUT()

        let result = sut.shouldShowCongratulations(
            entryDate: now,
            amountBefore: 1_800,
            amountAfter: 2_000,
            dailyGoal: 2_000
        )

        XCTAssertTrue(result)
    }

    func testShouldShowCongratulations_whenTodayExceedsGoal_returnsTrue() {
        let sut = makeSUT()

        let result = sut.shouldShowCongratulations(
            entryDate: now,
            amountBefore: 1_900,
            amountAfter: 2_200,
            dailyGoal: 2_000
        )

        XCTAssertTrue(result)
    }

    func testShouldShowCongratulations_whenAmountWasAlreadyAtGoal_returnsFalse() {
        let sut = makeSUT()

        let result = sut.shouldShowCongratulations(
            entryDate: now,
            amountBefore: 2_000,
            amountAfter: 2_200,
            dailyGoal: 2_000
        )

        XCTAssertFalse(result)
    }

    func testShouldShowCongratulations_whenAmountRemainsBelowGoal_returnsFalse() {
        let sut = makeSUT()

        let result = sut.shouldShowCongratulations(
            entryDate: now,
            amountBefore: 1_500,
            amountAfter: 1_800,
            dailyGoal: 2_000
        )

        XCTAssertFalse(result)
    }

    func testShouldShowCongratulations_whenEntryIsInPast_returnsFalse() {
        let sut = makeSUT()

        let result = sut.shouldShowCongratulations(
            entryDate: now.addingTimeInterval(-86_400),
            amountBefore: 1_800,
            amountAfter: 2_000,
            dailyGoal: 2_000
        )

        XCTAssertFalse(result)
    }

    func testShouldShowCongratulations_whenEntryIsInFuture_returnsFalse() {
        let sut = makeSUT()

        let result = sut.shouldShowCongratulations(
            entryDate: now.addingTimeInterval(86_400),
            amountBefore: 1_800,
            amountAfter: 2_000,
            dailyGoal: 2_000
        )

        XCTAssertFalse(result)
    }

    // MARK: - Helpers

    private var now: Date {
        Date(timeIntervalSince1970: 1_752_926_400)
    }

    private func makeSUT() -> GoalAchievementService {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt

        return GoalAchievementService(
            dateProvider: FixedDateProvider(now: now),
            calendar: calendar
        )
    }
}

private struct FixedDateProvider: DateProviding {
    let now: Date
}
