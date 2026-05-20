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
            Text("Select Date")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            DatePicker(
                "Date",
                selection: Binding(
                    get: {
                        selectedDate
                    },
                    set: { newDate in
                        onSelectDate(newDate)
                    }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
        }
        .padding(AppSpacing.lg)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
