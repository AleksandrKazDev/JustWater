//
//  SettingsSectionTitle.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import SwiftUI

struct SettingsSectionTitle: View {
    
    // MARK: - Properties
    
    let title: String
    
    // MARK: - Body
    
    var body: some View {
        Text(title)
            .font(AppTypography.headline)
            .foregroundStyle(AppColors.primaryText)
    }
}
