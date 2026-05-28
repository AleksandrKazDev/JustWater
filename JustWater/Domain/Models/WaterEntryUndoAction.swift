//
//  WaterEntryUndoAction.swift
//  JustWater
//
//  Created by сонный on 25.05.2026.
//

import Foundation

enum WaterEntryUndoAction {
    case added(WaterEntrySnapshot)
    case deleted(WaterEntrySnapshot)
    
    var message: String {
        switch self {
        case .added:
            return String(localized: "undo.added")
            
        case .deleted:
            return String(localized: "undo.deleted")
        }
    }
}
