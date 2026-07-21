//
//  BackupFileNameFormatter.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

enum BackupFileNameFormatter {

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(
            identifier: .gregorian
        )
        formatter.locale = Locale(
            identifier: "en_US_POSIX"
        )
        formatter.timeZone = TimeZone(
            secondsFromGMT: 0
        )
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"

        return formatter
    }()

    static func fileName(
        createdAt: Date
    ) -> String {
        "JustWaterBackup-\(formatter.string(from: createdAt)).json"
    }
}
