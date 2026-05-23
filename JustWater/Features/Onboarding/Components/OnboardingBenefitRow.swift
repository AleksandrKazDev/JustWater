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
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.primaryBlue)
                .frame(width: 38, height: 38)
                .background {
                    Circle()
                        .fill(AppColors.lightBlue.opacity(0.22))
                }
                .overlay {
                    Circle()
                        .stroke(
                            AppColors.glassStroke.opacity(0.14),
                            lineWidth: 1
                        )
                }
            
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
}
