//
//  PressableScaleButtonStyle.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct PressableScaleButtonStyle: ButtonStyle {
    
    // MARK: - Properties
    
    private let scale: CGFloat
    private let pressedBrightness: Double
    
    // MARK: - Initializer
    
    init(
        scale: CGFloat = 0.97,
        pressedBrightness: Double = -0.025
    ) {
        self.scale = scale
        self.pressedBrightness = pressedBrightness
    }
    
    // MARK: - Body
    
    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .brightness(configuration.isPressed ? pressedBrightness : 0)
            .animation(
                .spring(response: 0.24, dampingFraction: 0.82),
                value: configuration.isPressed
            )
    }
}
