//
//  SettingsLabel.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import SwiftUI

struct SettingsLabel: View {
    
    // MARK: - Properties
    
    let title: String
    let subtitle: String
    let systemImage: String
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            SettingsIconView(systemImage: systemImage)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }
}
