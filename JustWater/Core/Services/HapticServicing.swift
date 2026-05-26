//
//  HapticServicing.swift
//  JustWater
//
//  Created by сонный on 26.05.2026.
//

import Foundation

@MainActor
protocol HapticServicing {
    func selection()
    func success()
    func warning()
    func lightImpact()
}

@MainActor
final class AppHapticService: HapticServicing {
    
    func selection() {
        HapticService.selection()
    }
    
    func success() {
        HapticService.success()
    }
    
    func warning() {
        HapticService.warning()
    }
    
    func lightImpact() {
        HapticService.lightImpact()
    }
}
