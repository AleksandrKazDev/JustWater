//
//  BackupJSONCoder.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

enum BackupJSONCoder {

    static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(
                makeDateFormatter(
                    includingFractionalSeconds: true
                ).string(from: date)
            )
        }
        encoder.outputFormatting = [
            .sortedKeys
        ]

        return encoder
    }

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)

            let date = makeDateFormatter(
                includingFractionalSeconds: true
            ).date(from: value)
            ?? makeDateFormatter(
                includingFractionalSeconds: false
            ).date(from: value)

            guard let date else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid backup date."
                )
            }

            return date
        }

        return decoder
    }

    private static func makeDateFormatter(
        includingFractionalSeconds: Bool
    ) -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        if includingFractionalSeconds {
            formatter.formatOptions.insert(.withFractionalSeconds)
        }

        formatter.timeZone = TimeZone(
            secondsFromGMT: 0
        )

        return formatter
    }
}
