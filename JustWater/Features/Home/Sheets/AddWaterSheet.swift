//
//  AddWaterSheet.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

struct AddWaterSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    
    let presets: [Int]
    let onAdd: (Int) -> Void
    
    private let minimumAmount = 1
    private let maximumAmount = 5000
    
    @State private var customAmountText = ""
    
    private var customAmount: Int? {
        guard let amount = Int(customAmountText),
              amount >= minimumAmount,
              amount <= maximumAmount
        else {
            return nil
        }
        
        return amount
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            header
            
            presetSection
            
            customInputSection
            
            PrimaryButton(title: "Add Water", systemImage: "plus") {
                guard let amount = customAmount, amount > 0 else { return }
                HapticService.selection()
                onAdd(amount)
                dismiss()
            }
            .opacity(customAmount == nil ? 0.45 : 1)
            .disabled(customAmount == nil)
        }
        .padding(AppSpacing.lg)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .background(AppColors.background)
    }
    
    private var header: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Add Water")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text("Choose a preset or enter custom amount")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    private var presetSection: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(presets, id: \.self) { amount in
                QuickAddButton(amount: amount) {
                    HapticService.selection()
                    onAdd(amount)
                    dismiss()
                }
            }
        }
    }
    
    private var customInputSection: some View {
        GlassCard {
            HStack {
                TextField("Custom amount", text: $customAmountText)
                    .keyboardType(.numberPad)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                    .onChange(of: customAmountText) { _, newValue in
                        customAmountText = newValue.filter(\.isNumber)
                    }
                Text("ml")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        
    }
}

#Preview {
    AddWaterSheet(
        presets: [100, 200, 300, 500],
        onAdd: { _ in }
    )
}
