//
//  OnboardingStepIndicator.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct OnboardingStepIndicator: View {
    
    // MARK: - Properties
    
    let currentIndex: Int
    let totalCount: Int
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(0..<totalCount, id: \.self) { index in
                Capsule()
                    .fill(
                        index == currentIndex
                        ? AppColors.primaryBlue.opacity(0.92)
                        : AppColors.secondaryText.opacity(0.16)
                    )
                    .frame(
                        width: index == currentIndex ? 26 : 8,
                        height: 8
                    )
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background {
            Capsule()
                .fill(AppColors.cardBackground.opacity(0.62))
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .opacity(0.22)
                }
        }
        .overlay {
            Capsule()
                .stroke(
                    AppColors.glassStroke.opacity(0.16),
                    lineWidth: 1
                )
        }
        .animation(
            .spring(response: 0.35, dampingFraction: 0.85),
            value: currentIndex
        )
    }
}
