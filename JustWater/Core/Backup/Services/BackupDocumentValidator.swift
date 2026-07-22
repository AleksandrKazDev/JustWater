//
//  BackupDocumentValidator.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation

enum BackupDocumentValidationError: Error {
    case invalidFormat
    case unsupportedSchemaVersion
    case invalidData
}

struct BackupDocumentValidator {

    private let calendar: Calendar

    init(
        calendar: Calendar
    ) {
        self.calendar = calendar
    }

    func validate(
        _ document: BackupDocumentV1
    ) throws {
        guard document.format == BackupDocumentV1.format else {
            throw BackupDocumentValidationError.invalidFormat
        }

        guard document.schemaVersion == BackupDocumentV1.schemaVersion else {
            throw BackupDocumentValidationError.unsupportedSchemaVersion
        }

        guard hasUniqueValues(document.entries.map(\.id)),
              hasUniqueValues(document.goalHistory.map(\.id)),
              hasUniqueValues(
                document.goalHistory.map {
                    normalizedDay($0.effectiveDate)
                }
              ),
              hasUniqueValues(
                document.streakDays.map {
                    normalizedDay($0.dayStartDate)
                }
              ),
              isValid(date: document.createdAt),
              document.settings.dailyGoal > 0,
              (0...23).contains(document.settings.reminderStartHour),
              (0...23).contains(document.settings.reminderEndHour)
        else {
            throw BackupDocumentValidationError.invalidData
        }

        for entry in document.entries {
            guard entry.amount > 0,
                  isValid(date: entry.date)
            else {
                throw BackupDocumentValidationError.invalidData
            }
        }

        for goal in document.goalHistory {
            guard goal.dailyGoal > 0,
                  isValid(date: goal.effectiveDate)
            else {
                throw BackupDocumentValidationError.invalidData
            }
        }

        for streakDay in document.streakDays {
            guard isValid(date: streakDay.dayStartDate),
                  isValid(date: streakDay.createdAt)
            else {
                throw BackupDocumentValidationError.invalidData
            }
        }
    }

    private func normalizedDay(
        _ date: Date
    ) -> Date {
        calendar.startOfDay(for: date)
    }

    private func hasUniqueValues<Value: Hashable>(
        _ values: [Value]
    ) -> Bool {
        Set(values).count == values.count
    }

    private func isValid(
        date: Date
    ) -> Bool {
        date.timeIntervalSinceReferenceDate.isFinite
    }
}
