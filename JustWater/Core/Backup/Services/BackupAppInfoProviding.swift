//
//  BackupAppInfoProviding.swift
//  JustWater
//
//  Created by сонный on 20.07.2026.
//

import Foundation

protocol BackupAppInfoProviding {
    var appVersion: String { get }
    var buildNumber: String { get }
}

struct BundleBackupAppInfoProvider: BackupAppInfoProviding {

    private let bundle: Bundle

    init(
        bundle: Bundle = .main
    ) {
        self.bundle = bundle
    }

    var appVersion: String {
        bundle.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String ?? "unknown"
    }

    var buildNumber: String {
        bundle.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "unknown"
    }
}
