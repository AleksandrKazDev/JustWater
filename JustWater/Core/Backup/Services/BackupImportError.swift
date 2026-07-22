//
//  BackupImportError.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation

enum BackupImportError: Error, Equatable {
    case cannotReadFile
    case fileTooLarge
    case malformedBackup
    case invalidFormat
    case unsupportedSchemaVersion
    case invalidData
}
