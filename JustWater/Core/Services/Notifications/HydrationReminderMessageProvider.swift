//
//  HydrationReminderMessageProvider.swift
//  JustWater
//
//  Created by сонный on 29.05.2026.
//

import Foundation

enum HydrationReminderMessageProvider {
    
    // MARK: - Private Properties
    
    private static let titleKey = "notification.hydration.title"
    
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
        localizedString(
            for: titleKey
        )
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
                    localizedString(for: key)
                )
            }
        }
        
        return result
    }
    
    // MARK: - Private Methods
    
    private static func localizedString(
        for key: String
    ) -> String {
        let languageIdentifier = Bundle.main.preferredLocalizations.first
            ?? Locale.current.identifier
        
        let locale = Locale(
            identifier: languageIdentifier
        )
        
        return String(
            localized: String.LocalizationValue(key),
            locale: locale
        )
    }
}
