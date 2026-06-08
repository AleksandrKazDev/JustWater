//
//  CustomGoalSection.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct CustomGoalSection: View {
    
    // MARK: - Binding
    
    @Binding var customGoalText: String
    var focusedField: FocusState<CalculatorFocusedField?>.Binding
    
    // MARK: - Properties
    
    let customGoal: Int?
    let measurementUnit: MeasurementUnit
    let maximumGoalInput: Int
    let onTextChange: (String) -> Void
    let onUse: (Int) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(String(localized: "Custom Goal"))
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            VStack(spacing: AppSpacing.md) {
                inputRow
                
                if let customGoal {
                    useCustomGoalButton(customGoal)
                }
            }
            .padding(AppSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.lgs)
                    .fill(AppColors.cardBackground)
            }
            .animation(
                .spring(response: 0.35, dampingFraction: 0.9),
                value: customGoal
            )
        }
    }
    
    // MARK: - Components
    
    private var inputRow: some View {
        HStack(spacing: AppSpacing.sm) {
            TextField(
                inputPlaceholder,
                text: $customGoalText
            )
            .focused(focusedField, equals: .customGoal)
            .keyboardType(
                measurementUnit == .milliliters ? .numberPad : .decimalPad
            )
            .font(AppTypography.body)
            .foregroundStyle(AppColors.primaryText)
            .onChange(of: customGoalText) { _, newValue in
                onTextChange(newValue)
            }
            
            Text(measurementUnit.shortTitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
    
    private func useCustomGoalButton(
        _ goal: Int
    ) -> some View {
        Button {
            HapticService.success()
            onUse(goal)
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                
                Text(String(localized: "Use Custom Goal"))
                    .font(AppTypography.body)
            }
            .foregroundStyle(AppColors.primaryBlue)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                Capsule()
                    .fill(AppColors.lightBlue.opacity(0.28))
            }
        }
        .buttonStyle(.plain)
        .transition(
            .opacity.combined(
                with: .move(edge: .top)
            )
        )
    }
    
    // MARK: - Private
    
    private var inputPlaceholder: String {
        "1 - \(maximumGoalInput)"
    }
}
