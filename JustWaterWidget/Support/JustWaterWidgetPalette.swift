//
//  JustWaterWidgetPalette.swift
//  JustWaterWidgetExtension
//
//  Created by сонный on 10.06.2026.
//

import SwiftUI

struct JustWaterWidgetPalette {
    
    // MARK: - Background
    
    var background: LinearGradient {
        LinearGradient(
            colors: [
                Color("WidgetBackgroundStart"),
                Color("WidgetBackgroundEnd")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Text
    
    var primaryText: Color {
        Color("WidgetPrimaryText")
    }
    
    var secondaryText: Color {
        Color("WidgetSecondaryText")
    }
    
    var accentText: Color {
        Color("WidgetAccentText")
    }
    
    // MARK: - Effects
    
    var accentGlow: Color {
        Color("WidgetAccentGlow").opacity(0.22)
    }
    
    var secondaryGlow: Color {
        Color("WidgetSecondaryGlow").opacity(0.34)
    }
}
