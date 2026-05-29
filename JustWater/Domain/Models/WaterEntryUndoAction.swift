//
//  WaterEntryUndoAction.swift
//  JustWater
//
//  Created by сонный on 25.05.2026.
//

import Foundation

enum WaterEntryUndoAction: Equatable {
    case added(WaterEntrySnapshot)
    case deleted(WaterEntrySnapshot)
    
    var message: String {
        switch self {
        case .added(let snapshot):
            return String(
                format: String(localized: "undo.added"),
                snapshot.drinkType.title
            )
            
        case .deleted(let snapshot):
            return String(
                format: String(localized: "undo.deleted"),
                snapshot.drinkType.title
            )
        }
    }
}
