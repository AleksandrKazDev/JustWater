//
//  HapticService.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation
import UIKit

enum HapticService {
    
    // MARK: - Public Methods
    
    static func selection() {
        guard isEnabled else { return }
        
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    static func success() {
        guard isEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    static func warning() {
        guard isEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    static func lightImpact() {
        guard isEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Private Properties
    
    private static var isEnabled: Bool {
        AppSettingsStorage.isHapticsEnabled
    }
}
