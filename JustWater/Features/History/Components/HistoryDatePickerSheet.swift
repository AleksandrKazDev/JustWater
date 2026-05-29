//
//  HistoryDatePickerSheet.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HistoryDatePickerSheet: View {
    
    // MARK: - Properties
    
    let selectedDate: Date
    let onSelectDate: (Date) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Text(String(localized: "Select Date"))
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
                .padding(.top, AppSpacing.sm)
            
            DatePicker(
                "Date",
                selection: Binding(
                    get: {
                        selectedDate
                    },
                    set: { newDate in
                        HapticService.selection()
                        onSelectDate(newDate)
                    }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(AppColors.primaryBlue)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
        .background {
            AppColors.background
                .ignoresSafeArea()
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppColors.background)
    }
}
