//
//  HydrationReminderMessageProvider.swift
//  JustWater
//
//  Created by сонный on 29.05.2026.
//

import Foundation

enum HydrationReminderMessageProvider {
    
    // MARK: - Private Properties
    
    private static let bodyKeys = [
        "notification.hydration.body.1",
        "notification.hydration.body.2",
        "notification.hydration.body.3",
        "notification.hydration.body.4",
        "notification.hydration.body.5",
        "notification.hydration.body.6",
        "notification.hydration.body.7",
        "notification.hydration.body.8",
        "notification.hydration.body.9",
        "notification.hydration.body.10"
    ]
    
    // MARK: - Public Methods
    
    static func title() -> String {
        String(localized: "notification.hydration.title")
    }
    
    static func shuffledBodies(
        count: Int
    ) -> [String] {
        guard count > 0 else {
            return []
        }
        
        var result: [String] = []
        
        while result.count < count {
            let shuffledKeys = bodyKeys.shuffled()
            
            for key in shuffledKeys {
                guard result.count < count else {
                    break
                }
                
                result.append(
                    String(localized: String.LocalizationValue(key))
                )
            }
        }
        
        return result
    }
}
