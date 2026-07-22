//
//  PreparedBackupImport.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import Foundation

struct PreparedBackupImport: Equatable, Sendable {
    let preview: BackupImportPreview
    let data: Data
}
