//
//  QuickAddButton.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

enum QuickAddButtonSize {
    case regular
    case compact
    
    var height: CGFloat {
        switch self {
        case .regular:
            return 44
            
        case .compact:
            return 42
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .regular:
            return AppSpacing.md
            
        case .compact:
            return AppSpacing.xs
        }
    }
}

struct QuickAddButton: View {
    
    // MARK: - Properties
    
    let amount: Int
    let size: QuickAddButtonSize
    let action: () -> Void
    
    // MARK: - Initializer
    
    init(
        amount: Int,
        size: QuickAddButtonSize = .regular,
        action: @escaping () -> Void
    ) {
        self.amount = amount
        self.size = size
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button {
            action()
        } label: {
            Text("+\(amount) ml")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.primaryBlue)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .allowsTightening(true)
                .padding(.horizontal, size.horizontalPadding)
                .frame(maxWidth: .infinity)
                .frame(height: size.height)
                .background {
                    Capsule()
                        .fill(AppColors.glassFill)
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .opacity(0.38)
                        }
                }
                .overlay {
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppColors.glassHighlight.opacity(0.55),
                                    AppColors.glassStroke.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: AppColors.blueGlow.opacity(0.06),
                    radius: 12,
                    x: 0,
                    y: 6
                )
        }
        .buttonStyle(
            PressableScaleButtonStyle(
                scale: 0.96,
                pressedBrightness: -0.02
            )
        )
    }
}
