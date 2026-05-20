//
//  WaterEntryEditorMode.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import Foundation

enum WaterEntryEditorMode: Identifiable {
    case add(date: Date)
    case edit(entry: WaterEntry)
    
    var id: String {
        switch self {
        case .add(let date):
            return "add-\(date.timeIntervalSince1970)"
            
        case .edit(let entry):
            return "edit-\(entry.id.uuidString)"
        }
    }
    
    var title: String {
        switch self {
        case .add:
            return "Add Entry"
            
        case .edit:
            return "Edit Entry"
        }
    }
    
    var actionTitle: String {
        switch self {
        case .add:
            return "Save Entry"
            
        case .edit:
            return "Save Changes"
        }
    }
    
    var selectedDate: Date {
        switch self {
        case .add(let date):
            return date
            
        case .edit(let entry):
            return entry.date
        }
    }
    
    var initialAmountText: String {
        switch self {
        case .add:
            return ""
            
        case .edit(let entry):
            return "\(entry.amount)"
        }
    }
    
    var initialDrinkType: DrinkType {
        switch self {
        case .add:
            return .water
            
        case .edit(let entry):
            return entry.drinkType
        }
    }
}
