//
//  AddWaterSheet.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

struct AddWaterSheet: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    
    let presets: [Int]
    let onAdd: (Int, DrinkType) -> Void
    
    // MARK: - Constants
    
    private let minimumAmount = 1
    private let maximumAmount = 10_000
    
    // MARK: - State
    
    @State private var customAmountText = ""
    @State private var selectedDrinkType: DrinkType = .water
    
    // MARK: - Focus
    
    @FocusState private var isCustomAmountFocused: Bool
    
    // MARK: - Computed Properties
    
    private var customAmount: Int? {
        guard let amount = Int(customAmountText),
              amount >= minimumAmount,
              amount <= maximumAmount else {
            return nil
        }
        
        return amount
    }
    
    private var isCustomAmountValid: Bool {
        customAmount != nil
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    header
                    
                    DrinkTypeSelector(
                        selectedDrinkType: $selectedDrinkType
                    )
                    
                    presetSection
                    
                    customInputSection
                    
                    addButton
                }
                .padding(AppSpacing.lg)
                .padding(.bottom, AppSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppColors.background)
    }
    
    // MARK: - Components
    
    private var header: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Add Drink")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text("Choose a drink type and amount")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    private var presetSection: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(presets, id: \.self) { amount in
                QuickAddButton(
                    amount: amount,
                    size: .compact
                ) {
                    addPresetAmount(amount)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var customInputSection: some View {
        GlassCard {
            HStack(spacing: AppSpacing.sm) {
                TextField(
                    "Custom amount",
                    text: $customAmountText
                )
                .focused($isCustomAmountFocused)
                .keyboardType(.numberPad)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
                .onChange(of: customAmountText) { _, newValue in
                    updateCustomAmountText(newValue)
                }
                
                Text("ml")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }
    
    private var addButton: some View {
        PrimaryButton(
            title: "Add Drink",
            systemImage: "plus"
        ) {
            addCustomAmount()
        }
        .opacity(isCustomAmountValid ? 1 : 0.45)
        .disabled(!isCustomAmountValid)
    }
    
    // MARK: - Actions
    
    private func addPresetAmount(
        _ amount: Int
    ) {
        HapticService.selection()
        
        onAdd(
            amount,
            selectedDrinkType
        )
        
        dismiss()
    }
    
    private func addCustomAmount() {
        guard let amount = customAmount else { return }
        
        isCustomAmountFocused = false
        
        onAdd(
            amount,
            selectedDrinkType
        )
        
        dismiss()
    }
    
    // MARK: - Private Methods
    
    private func updateCustomAmountText(
        _ newValue: String
    ) {
        let digitsOnly = newValue.filter(\.isNumber)
        
        guard let amount = Int(digitsOnly) else {
            customAmountText = digitsOnly
            return
        }
        
        if amount > maximumAmount {
            customAmountText = "\(maximumAmount)"
        } else {
            customAmountText = digitsOnly
        }
    }
}
