//
//  AppSettingsStorageTestSupport.swift
//  JustWaterTests
//
//  Created by Codex on 13.06.2026.
//

import Foundation
@testable import JustWater

enum AppSettingsStorageTestSupport {
    
    private static let suiteName = "JustWaterTests"
    
    static func setUpIsolatedDefaults() {
        let defaults = makeDefaults()
        defaults.removePersistentDomain(
            forName: suiteName
        )
        
        AppSettingsStorage.useDefaults(defaults)
    }
    
    static func tearDownIsolatedDefaults() {
        AppSettingsStorage.useStandardDefaults()
        
        makeDefaults().removePersistentDomain(
            forName: suiteName
        )
    }
    
    private static func makeDefaults() -> UserDefaults {
        guard let defaults = UserDefaults(
            suiteName: suiteName
        ) else {
            preconditionFailure("Unable to create isolated JustWater test defaults")
        }
        
        return defaults
    }
}
