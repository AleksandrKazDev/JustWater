//
//  OnboardingHeroDrop.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct OnboardingHeroDrop: View {
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.primaryBlue.opacity(0.22),
                            AppColors.lightBlue.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 190, height: 190)
                .blur(radius: 4)
            
            Circle()
                .fill(AppColors.cardBackground.opacity(0.92))
                .frame(width: 148, height: 148)
                .overlay {
                    Circle()
                        .stroke(
                            AppColors.primaryBlue.opacity(0.22),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: AppColors.primaryBlue.opacity(0.18),
                    radius: 24,
                    x: 0,
                    y: 12
                )
            
            Image(systemName: "drop.fill")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            AppColors.primaryBlue,
                            AppColors.lightBlue
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(height: 220)
    }
}
