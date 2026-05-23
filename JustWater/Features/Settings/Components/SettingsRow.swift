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
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            
            Spacer(minLength: AppSpacing.sm)
            
            Text(value)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
    }
}
