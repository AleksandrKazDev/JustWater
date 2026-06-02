//
//  HistoryDatePickerTitleView.swift
//  JustWater
//
//  Created by сонный on 02.06.2026.
//

import SwiftUI

struct HistoryDatePickerTitleView: View {
    
    // MARK: - Body
    
    var body: some View {
        Text(String(localized: "Select Date"))
            .font(AppTypography.title2)
            .foregroundStyle(AppColors.primaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.top, AppSpacing.lg)
            .frame(maxWidth: .infinity)
    }
}
