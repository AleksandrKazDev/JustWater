//
//  CalculatorHeaderView.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct CalculatorHeaderView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Water Goal")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text("Get a personalized daily hydration recommendation.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
}
