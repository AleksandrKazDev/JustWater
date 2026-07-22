//
//  GoalAchievementService.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation

struct GoalAchievementService {

    // MARK: - Properties

    private let dateProvider: DateProviding
    private let calendar: Calendar

    // MARK: - Initializer

    init(
        dateProvider: DateProviding = SystemDateProvider(),
        calendar: Calendar = .current
    ) {
        self.dateProvider = dateProvider
        self.calendar = calendar
    }

    // MARK: - Public Methods

    func shouldShowCongratulations(
        entryDate: Date,
        amountBefore: Int,
        amountAfter: Int,
        dailyGoal: Int
    ) -> Bool {
        calendar.isDate(
            entryDate,
            inSameDayAs: dateProvider.now
        )
        && amountBefore < dailyGoal
        && amountAfter >= dailyGoal
    }
}
