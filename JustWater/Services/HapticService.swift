//
//  HapticService.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation
import UIKit

enum HapticService {
    
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    static func lightImpact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
