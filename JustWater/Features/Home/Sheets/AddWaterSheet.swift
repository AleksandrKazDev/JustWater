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
    let measurementUnit: MeasurementUnit
    let onAdd: (Int, DrinkType) -> Void
    
    // MARK: - Constants
    
    private let minimumAmount = 1
    private let maximumAmountMilliliters = 10_000
    private let maximumAmountFluidOunces = 338
    
    // MARK: - State
    
    @State private var customAmountText = ""
    @State private var selectedDrinkType: DrinkType = .water
    
    // MARK: - Focus
    
    @FocusState private var isCustomAmountFocused: Bool
    
    // MARK: - Computed Properties
    
    private var maximumInputAmount: Int {
        switch measurementUnit {
        case .milliliters:
            return maximumAmountMilliliters
            
        case .fluidOunces:
            return maximumAmountFluidOunces
        }
    }
    
    private var customAmount: Int? {
        guard let inputAmount = decimalValue(from: customAmountText),
              inputAmount >= Double(minimumAmount),
              inputAmount <= Double(maximumInputAmount) else {
            return nil
        }
        
        return MeasurementUnitConverter.milliliters(
            from: inputAmount,
            unit: measurementUnit
        )
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
                    measurementUnit: measurementUnit,
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
                    String(localized: "Custom amount"),
                    text: $customAmountText
                )
                .focused($isCustomAmountFocused)
                .keyboardType(
                    measurementUnit == .milliliters ? .numberPad : .decimalPad
                )
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
                .onChange(of: customAmountText) { _, newValue in
                    updateCustomAmountText(newValue)
                }
                
                Text(measurementUnit.shortTitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }
    
    private var addButton: some View {
        PrimaryButton(
            title: String(localized: "Add Drink"),
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
        switch measurementUnit {
        case .milliliters:
            updateIntegerAmountText(newValue)
            
        case .fluidOunces:
            updateDecimalAmountText(newValue)
        }
    }
    
    private func updateIntegerAmountText(
        _ newValue: String
    ) {
        let digitsOnly = newValue.filter(\.isNumber)
        
        guard let amount = Int(digitsOnly) else {
            customAmountText = digitsOnly
            return
        }
        
        if amount > maximumInputAmount {
            customAmountText = "\(maximumInputAmount)"
        } else {
            customAmountText = digitsOnly
        }
    }
    
    private func updateDecimalAmountText(
        _ newValue: String
    ) {
        var result = ""
        var hasSeparator = false
        
        for character in newValue {
            if character.isNumber {
                result.append(character)
            } else if character == "." || character == "," {
                guard !hasSeparator else { continue }
                
                result.append(character)
                hasSeparator = true
            }
        }
        
        guard let amount = decimalValue(from: result) else {
            customAmountText = result
            return
        }
        
        if amount > Double(maximumInputAmount) {
            customAmountText = "\(maximumInputAmount)"
        } else {
            customAmountText = result
        }
    }
    
    private func decimalValue(
        from text: String
    ) -> Double? {
        let normalizedText = text
            .replacingOccurrences(of: ",", with: ".")
        
        return Double(normalizedText)
    }
}
