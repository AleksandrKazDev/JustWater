//
//  PrimaryButton.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

struct PrimaryButton: View {
    
    let title: String
    let systemImage: String?
    let action: () -> Void
    
    init(
        title: String,
        systemImage: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .semibold))
                }
                
                Text(title)
                    .font(AppTypography.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.pill, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.primaryBlue,
                                AppColors.deepBlue
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(
                color: AppColors.primaryBlue.opacity(0.28),
                radius: 16,
                x: 0,
                y: 10
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        PrimaryButton(
            title: "Add Water",
            systemImage: "plus"
        ) {}
        .padding(AppSpacing.lg)
    }
}
