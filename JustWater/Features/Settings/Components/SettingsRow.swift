//
//  SettingsRow.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import SwiftUI

struct SettingsRow: View {
    
    // MARK: - Properties
    
    let title: String
    let value: String
    let systemImage: String
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            SettingsIconView(systemImage: systemImage)
            
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            Text(value)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
}
