//
//  PrimaryButton.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

struct PrimaryButton: View {
    
    // MARK: - Properties
    
    let title: String
    let systemImage: String?
    let action: () -> Void
    
    // MARK: - Environment
    
    @Environment(\.isEnabled) private var isEnabled
    
    // MARK: - Initializer
    
    init(
        title: String,
        systemImage: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button {
            HapticService.selection()
            action()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(title)
                    .font(AppTypography.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background {
                Capsule()
                    .fill(baseGradient)
            }
            .overlay {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(isEnabled ? 0.16 : 0.06)
            }
            .overlay {
                Capsule()
                    .fill(glassHighlight)
                    .blendMode(.screen)
                    .opacity(isEnabled ? 0.35 : 0.12)
            }
            .overlay {
                Capsule()
                    .stroke(borderGradient, lineWidth: 1)
            }
            .shadow(
                color: AppColors.blueGlow.opacity(isEnabled ? 0.18 : 0),
                radius: 18,
                x: 0,
                y: 10
            )
            .opacity(isEnabled ? 1 : 0.45)
        }
        .buttonStyle(
            PressableScaleButtonStyle(
                scale: 0.98,
                pressedBrightness: -0.025))
    }
    
    // MARK: - Gradients
    
    private var baseGradient: LinearGradient {
        LinearGradient(
            colors: [
                AppColors.primaryBlue,
                AppColors.deepBlue
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var glassHighlight: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(0.28),
                .white.opacity(0.06),
                .clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(isEnabled ? 0.34 : 0.10),
                .white.opacity(isEnabled ? 0.10 : 0.04),
                .white.opacity(isEnabled ? 0.18 : 0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
