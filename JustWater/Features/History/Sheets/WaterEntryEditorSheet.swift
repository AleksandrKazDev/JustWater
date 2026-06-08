//
//  WaterEntryEditorSheet.swift
//  JustWater
//
//  Created by сонный on 19.05.2026.
//

import SwiftUI

struct WaterEntryEditorSheet: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var amountText: String
    @State private var selectedTime: Date
    @State private var selectedDrinkType: DrinkType
    
    // MARK: - Focus
    
    @FocusState private var isAmountFocused: Bool
    
    // MARK: - Properties
    
    private let mode: WaterEntryEditorMode
    private let measurementUnit: MeasurementUnit
    private let onSave: (Int, Date, DrinkType) -> Void
    
    // MARK: - Constants
    
    private let minimumAmount = 1
    private let maximumAmountMilliliters = 10_000
    private let maximumAmountFluidOunces = 338
    
    // MARK: - Computed Properties
    
    private var maximumInputAmount: Int {
        switch measurementUnit {
        case .milliliters:
            return maximumAmountMilliliters
            
        case .fluidOunces:
            return maximumAmountFluidOunces
        }
    }
    
    private var amount: Int? {
        guard let inputAmount = decimalValue(from: amountText),
              inputAmount >= Double(minimumAmount),
              inputAmount <= Double(maximumInputAmount) else {
            return nil
        }
        
        return MeasurementUnitConverter.milliliters(
            from: inputAmount,
            unit: measurementUnit
        )
    }
    
    private var isSaveEnabled: Bool {
        amount != nil
    }
    
    private var selectedDateTitle: String {
        mode.selectedDate.formatted(
            .dateTime
                .day()
                .month(.wide)
        )
    }
    
    private var amountRangePlaceholder: String {
        "1 - \(maximumInputAmount)"
    }
    
    // MARK: - Initializer
    
    init(
        mode: WaterEntryEditorMode,
        measurementUnit: MeasurementUnit,
        onSave: @escaping (Int, Date, DrinkType) -> Void
    ) {
        self.mode = mode
        self.measurementUnit = measurementUnit
        self.onSave = onSave
        
        _amountText = State(
            initialValue: Self.initialAmountText(
                for: mode,
                measurementUnit: measurementUnit
            )
        )
        
        _selectedTime = State(
            initialValue: mode.selectedDate
        )
        
        _selectedDrinkType = State(
            initialValue: mode.initialDrinkType
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    header
                    
                    amountInput
                    
                    DrinkTypeSelector(
                        selectedDrinkType: $selectedDrinkType
                    )
                    
                    timePicker
                    
                    saveButton
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppColors.background)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    isAmountFocused = false
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var header: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(mode.title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text(selectedDateTitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var amountInput: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Amount")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            HStack(spacing: AppSpacing.sm) {
                TextField(
                    amountRangePlaceholder,
                    text: $amountText
                )
                .focused($isAmountFocused)
                .keyboardType(
                    measurementUnit == .milliliters ? .numberPad : .decimalPad
                )
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
                .onChange(of: amountText) { _, newValue in
                    updateAmountText(newValue)
                }
                
                Text(measurementUnit.shortTitle)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .padding(AppSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .fill(AppColors.glassFill)
                    .background {
                        RoundedRectangle(cornerRadius: AppRadius.lg)
                            .fill(.ultraThinMaterial)
                            .opacity(0.34)
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.glassHighlight.opacity(0.52),
                                AppColors.glassStroke.opacity(0.16)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
    }
    
    private var timePicker: some View {
        HStack {
            Text("Time")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            DatePicker(
                "Time",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(AppColors.primaryBlue)
        }
        .padding(AppSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .fill(AppColors.glassFill)
                .background {
                    RoundedRectangle(cornerRadius: AppRadius.lg)
                        .fill(.ultraThinMaterial)
                        .opacity(0.34)
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(
                    LinearGradient(
                        colors: [
                            AppColors.glassHighlight.opacity(0.52),
                            AppColors.glassStroke.opacity(0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
    
    private var saveButton: some View {
        PrimaryButton(
            title: mode.actionTitle,
            systemImage: "checkmark"
        ) {
            saveEntry()
        }
        .disabled(!isSaveEnabled)
        .opacity(isSaveEnabled ? 1 : 0.45)
    }
    
    // MARK: - Actions
    
    private func saveEntry() {
        guard let amount else { return }
        
        isAmountFocused = false
        
        let entryDate = mergedDate(
            mode.selectedDate,
            time: selectedTime
        )
        
        onSave(
            amount,
            entryDate,
            selectedDrinkType
        )
        
        dismiss()
    }
    
    // MARK: - Private Methods
    
    private func updateAmountText(
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
            amountText = digitsOnly
            return
        }
        
        if amount > maximumInputAmount {
            amountText = "\(maximumInputAmount)"
        } else {
            amountText = digitsOnly
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
            amountText = result
            return
        }
        
        if amount > Double(maximumInputAmount) {
            amountText = "\(maximumInputAmount)"
        } else {
            amountText = result
        }
    }

    private func decimalValue(
        from text: String
    ) -> Double? {
        let normalizedText = text
            .replacingOccurrences(of: ",", with: ".")
        
        return Double(normalizedText)
    }
    
    private func mergedDate(
        _ date: Date,
        time: Date
    ) -> Date {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )
        
        let timeComponents = calendar.dateComponents(
            [.hour, .minute],
            from: time
        )
        
        var components = DateComponents()
        components.year = dateComponents.year
        components.month = dateComponents.month
        components.day = dateComponents.day
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        
        return calendar.date(from: components) ?? date
    }
    
    private static func initialAmountText(
        for mode: WaterEntryEditorMode,
        measurementUnit: MeasurementUnit
    ) -> String {
        guard let amount = mode.initialAmount else {
            return ""
        }
        
        return MeasurementUnitFormatter()
            .inputString(
                fromMilliliters: amount,
                unit: measurementUnit
            )
    }
}
