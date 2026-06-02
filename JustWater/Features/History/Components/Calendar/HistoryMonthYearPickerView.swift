//
//  HistoryMonthYearPickerView.swift
//  JustWater
//
//  Created by сонный on 02.06.2026.
//

import SwiftUI

struct HistoryMonthYearPickerView: View {
    
    // MARK: - Properties
    
    let selectedMonth: Int
    let selectedYear: Int
    let yearRange: ClosedRange<Int>
    let monthNameProvider: (Int) -> String
    let onSelectMonth: (Int) -> Void
    let onSelectYear: (Int) -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            monthPicker
            yearPicker
        }
    }
    
    // MARK: - Month Picker
    
    private var monthPicker: some View {
        Picker(
            String(localized: "Month"),
            selection: Binding(
                get: {
                    selectedMonth
                },
                set: { newMonth in
                    HapticService.selection()
                    onSelectMonth(newMonth)
                }
            )
        ) {
            ForEach(1...12, id: \.self) { month in
                Text(monthNameProvider(month))
                    .tag(month)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
        .clipped()
    }
    
    // MARK: - Year Picker
    
    private var yearPicker: some View {
        Picker(
            String(localized: "Year"),
            selection: Binding(
                get: {
                    selectedYear
                },
                set: { newYear in
                    HapticService.selection()
                    onSelectYear(newYear)
                }
            )
        ) {
            ForEach(yearRange, id: \.self) { year in
                Text(String(year))
                    .tag(year)
            }
        }
        .pickerStyle(.wheel)
        .frame(maxWidth: .infinity)
        .clipped()
    }
}
