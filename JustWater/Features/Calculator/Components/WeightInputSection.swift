//
//  WeightInputSection.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct WeightInputSection: View {
    
    // MARK: - Binding
    
    @Binding var weightText: String
    var focusedField: FocusState<CalculatorFocusedField?>.Binding
    
    // MARK: - Properties
    
    let onChange: (String) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Weight (kg)")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            TextField(
                "Enter your weight",
                text: $weightText
            )
            .focused(focusedField, equals: .weight)
            .keyboardType(.numberPad)
            .font(AppTypography.body)
            .foregroundStyle(AppColors.primaryText)
            .padding(AppSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.lgs)
                    .fill(AppColors.glassFill)
                    .background {
                        RoundedRectangle(cornerRadius: AppRadius.lgs)
                            .fill(AppColors.cardBackground)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.lgs)
                            .stroke(AppColors.border, lineWidth: 1)
                    }
                    .onChange(of: weightText) { _, newValue in
                        onChange(newValue)
                    }
            }
        }
    }
}
