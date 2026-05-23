//
//  GenderPickerSection.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct GenderPickerSection: View {
    
    // MARK: - Properties
    
    let selectedGender: Gender
    let onSelect: (Gender) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Gender")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(Gender.allCases) { gender in
                    Button {
                        HapticService.selection()
                        onSelect(gender)
                    } label: {
                        Text(gender.title)
                            .font(AppTypography.body)
                            .foregroundStyle(
                                selectedGender == gender
                                ? .white
                                : AppColors.primaryText
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background {
                                RoundedRectangle(
                                    cornerRadius: AppRadius.lg
                                )
                                .fill(
                                    selectedGender == gender
                                    ? AppColors.primaryBlue
                                    : AppColors.cardBackground
                                )
                            }
                    }
                    .buttonStyle(
                        PressableScaleButtonStyle(
                            scale: 0.97,
                            pressedBrightness: -0.02
                        )
                    )
                }
            }
        }
    }
}
