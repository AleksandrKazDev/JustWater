//
//  TestHapticService.swift
//  JustWaterTests
//
//  Created by сонный on 26.05.2026.
//

import Foundation
@testable import JustWater

@MainActor
final class TestHapticService: HapticServicing {
    
    private(set) var selectionCallCount = 0
    private(set) var successCallCount = 0
    private(set) var warningCallCount = 0
    private(set) var lightImpactCallCount = 0
    
    func selection() {
        selectionCallCount += 1
    }
    
    func success() {
        successCallCount += 1
    }
    
    func warning() {
        warningCallCount += 1
    }
    
    func lightImpact() {
        lightImpactCallCount += 1
    }
}
