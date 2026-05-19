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
    
    @State private var amountText = ""
    @State private var selectedTime: Date
    
    // MARK: - Properties
    
    private let title: String
    private let selectedDate: Date
    private let onSave: (Int, Date) -> Void
    
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
    
    private var selectedDateTitle: String {
        selectedDate.formatted(
            .dateTime
                .day()
                .month(.wide)
        )
    }
    
    // MARK: - Initializer
    
    init(
        title: String = "Add Entry",
        selectedDate: Date,
        onSave: @escaping (Int, Date) -> Void
    ) {
        self.title = title
        self.selectedDate = selectedDate
        self.onSave = onSave
        
        _selectedTime = State(
            initialValue: selectedDate
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.xl) {
                header
                
                VStack(spacing: AppSpacing.lg) {
                    amountInput
                    timePicker
                }
                
                PrimaryButton(
                    title: "Save Entry",
                    systemImage: "checkmark"
                ) {
                    saveEntry()
                }
                .disabled(amount == nil)
                .opacity(amount == nil ? 0.45 : 1)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.xl)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColors.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Components
    
    private var header: some View {
        VStack(spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text("Add water for \(selectedDateTitle)")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
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
                RoundedRectangle(cornerRadius: 22)
                    .fill(AppColors.cardBackground)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(AppColors.border, lineWidth: 1)
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
        }
        .padding(AppSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(AppColors.cardBackground)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(AppColors.border, lineWidth: 1)
        }
    }
    
    // MARK: - Actions
    
    private func saveEntry() {
        guard let amount else { return }
        
        let entryDate = mergedDate(
            selectedDate,
            time: selectedTime
        )
        
        onSave(amount, entryDate)
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

// MARK: - Preview

//#Preview {
//    WaterEntryEditorSheet(
//        selectedDate: Date(),
//        onSave: { _, _ in }
//    )
//}
