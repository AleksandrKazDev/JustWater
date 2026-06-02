//
//  HistoryCalendarHeaderView.swift
//  JustWater
//
//  Created by сонный on 02.06.2026.
//

import SwiftUI

struct HistoryCalendarHeaderView: View {
    
    // MARK: - Properties
    
    let monthTitle: String
    let isMonthYearPickerPresented: Bool
    let onToggleMonthYearPicker: () -> Void
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            monthButton
            
            Spacer(minLength: AppSpacing.md)
            
            navigationButtons
        }
    }
    
    // MARK: - Month Button
    
    private var monthButton: some View {
        Button {
            HapticService.selection()
            onToggleMonthYearPicker()
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Text(monthTitle)
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Image(
                    systemName: isMonthYearPickerPresented
                    ? "chevron.down"
                    : "chevron.right"
                )
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.primaryBlue)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                HapticService.selection()
                onPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(AppColors.primaryBlue)
                    .frame(width: 40, height: 40)
            }
            
            Button {
                HapticService.selection()
                onNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(AppColors.primaryBlue)
                    .frame(width: 40, height: 40)
            }
        }
    }
}
