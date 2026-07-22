//
//  AppSettingsStorageTestSupport.swift
//  JustWaterTests
//
//  Created by сонный on 13.06.2026.
//

import Foundation
import Dispatch
@testable import JustWater

enum AppSettingsStorageTestSupport {
    
    private static let suiteName = "JustWaterTests"
    private static let semaphore = DispatchSemaphore(value: 1)
    private static var isolatedDefaults: UserDefaults?
    
    static func setUpIsolatedDefaults() {
        semaphore.wait()

        guard let defaults = UserDefaults(
            suiteName: suiteName
        ) else {
            semaphore.signal()
            preconditionFailure(
                "Failed to create isolated test defaults."
            )
        }

        defaults.removePersistentDomain(
            forName: suiteName
        )
        AppSettingsStorage.useDefaults(defaults)
        isolatedDefaults = defaults
    }
    
    static func tearDownIsolatedDefaults() {
        guard let isolatedDefaults else { return }
        
        defer {
            self.isolatedDefaults = nil
            semaphore.signal()
        }
        
        AppSettingsStorage.useStandardDefaults()
        isolatedDefaults.removePersistentDomain(
            forName: suiteName
        )
    }
}
