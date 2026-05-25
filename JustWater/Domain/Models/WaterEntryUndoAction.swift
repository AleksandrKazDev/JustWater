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
        case .added(let snapshot):
            return "\(snapshot.drinkType.title) added"
            
        case .deleted(let snapshot):
            return "\(snapshot.drinkType.title) deleted"
        }
    }
}
