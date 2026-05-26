//
//  TestErrorReporter.swift
//  JustWaterTests
//
//  Created by сонный on 26.05.2026.
//

import Foundation
@testable import JustWater

@MainActor
final class TestErrorReporter: ErrorReporting {
    
    // MARK: - Properties
    
    private(set) var reports: [ ( error: Error, context: String ) ] = []
    
    // MARK: - Public Methods
    
    func report(
        _ error: Error,
        context: String
    ) {
        reports.append(
            (
                error: error,
                context: context
            )
        )
    }
}
