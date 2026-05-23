//
//  OnboardingBenefitRow.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct OnboardingBenefitRow: View {
    
    // MARK: - Properties
    
    let title: String
    let subtitle: String
    let systemImage: String
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            icon
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: AppSpacing.sm)
        }
    }
    
    // MARK: - Components
    
    private var icon: some View {
        Image(systemName: systemImage)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(AppColors.primaryBlue)
            .frame(width: 42, height: 42)
            .background {
                Circle()
                    .fill(AppColors.lightBlue.opacity(0.20))
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.18)
                    }
            }
            .overlay {
                Circle()
                    .stroke(
                        AppColors.glassStroke.opacity(0.16),
                        lineWidth: 1
                    )
            }
    }
}
