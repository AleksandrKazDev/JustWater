//
//  CalculatorHeaderView.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct CalculatorHeaderView: View {
    
    // MARK: - Properties
    
    let showsTitle: Bool
    
    // MARK: - Initializer
    
    init(
        showsTitle: Bool = false
    ) {
        self.showsTitle = showsTitle
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            if showsTitle {
                Text("Water Goal")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.primaryText)
            }
            
            Text("Personalize your daily hydration target based on your body and activity.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppSpacing.md)
        }
        .padding(.top, showsTitle ? AppSpacing.md : AppSpacing.sm)
    }
}
