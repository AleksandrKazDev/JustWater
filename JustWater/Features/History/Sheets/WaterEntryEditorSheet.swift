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
    private let onSave: (Int, Date, DrinkType) -> Void
    
    // MARK: - Constants
    
    private let minimumAmount = 1
    private let maximumAmount = 10_000
    
    // MARK: - Computed Properties
    
    private var amount: Int? {
        guard let amount = Int(amountText),
              amount >= minimumAmount,
              amount <= maximumAmount else {
            return nil
        }
        
        return amount
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
    
    // MARK: - Initializer
    
    init(
        mode: WaterEntryEditorMode,
        onSave: @escaping (Int, Date, DrinkType) -> Void
    ) {
        self.mode = mode
        self.onSave = onSave
        
        _amountText = State(
            initialValue: mode.initialAmountText
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
                    "1 - 10000",
                    text: $amountText
                )
                .focused($isAmountFocused)
                .keyboardType(.numberPad)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
                .onChange(of: amountText) { _, newValue in
                    updateAmountText(newValue)
                }
                
                Text("ml")
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
        HapticService.success()
        
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
        let digitsOnly = newValue.filter(\.isNumber)
        
        guard let amount = Int(digitsOnly) else {
            amountText = digitsOnly
            return
        }
        
        if amount > maximumAmount {
            amountText = "\(maximumAmount)"
        } else {
            amountText = digitsOnly
        }
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
}
