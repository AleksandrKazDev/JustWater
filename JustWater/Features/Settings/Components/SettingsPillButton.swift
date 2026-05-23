//
//  SettingsPillButton.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import SwiftUI

struct SettingsPillButton: View {
    
    // MARK: - Properties
    
    let title: String
    
    // MARK: - Body
    
    var body: some View {
        Text(title)
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.primaryBlue)
            .lineLimit(1)
            .padding(.horizontal, AppSpacing.lg)
            .frame(height: 38)
            .background {
                Capsule()
                    .fill(AppColors.glassFill)
                    .background {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .opacity(0.28)
                    }
            }
            .overlay {
                Capsule()
                    .stroke(
                        AppColors.glassStroke.opacity(0.20),
                        lineWidth: 1
                    )
            }
    }
}
