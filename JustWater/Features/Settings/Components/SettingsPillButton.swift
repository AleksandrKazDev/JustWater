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
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 34)
            .background {
                Capsule()
                    .fill(AppColors.lightBlue.opacity(0.28))
            }
    }
}
