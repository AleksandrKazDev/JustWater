//
//  ErrorReporting.swift
//  JustWater
//
//  Created by сонный on 26.05.2026.
//

import Foundation
import OSLog

@MainActor
protocol ErrorReporting {
    
    func report(
        _ error: Error,
        context: String
    )
}

@MainActor
final class AppErrorReporter: ErrorReporting {
    
    // MARK: - Properties
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "JustWater",
        category: "AppError"
    )
    
    // MARK: - Public Methods
    
    func report(
        _ error: Error,
        context: String
    ) {
        logger.error(
            "\(context, privacy: .public): \(error.localizedDescription, privacy: .public)"
        )
    }
}
