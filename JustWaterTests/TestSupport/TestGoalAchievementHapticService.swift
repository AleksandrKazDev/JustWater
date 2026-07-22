//
//  TestGoalAchievementHapticService.swift
//  JustWaterTests
//
//  Created by сонный on 22.07.2026.
//

import Foundation
@testable import JustWater

@MainActor
final class TestGoalAchievementHapticService: GoalAchievementHapticServicing {

    private(set) var playCallCount = 0

    func play() {
        playCallCount += 1
    }
}
