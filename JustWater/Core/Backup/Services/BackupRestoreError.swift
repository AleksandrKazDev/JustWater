//
//  BackupRestoreError.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation

enum BackupRestoreError: Error, Equatable {
    case invalidPreparedBackup
    case cannotReadCurrentData
    case persistenceFailed
}
