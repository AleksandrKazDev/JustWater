//
//  ActivityLevelRow.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct ActivityLevelRow: View {
    
    // MARK: - Properties
    
    let level: ActivityLevel
    let isSelected: Bool
    let onSelect: () -> Void
    let onInfo: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            selectButton
            
            infoButton
        }
        .padding(.leading, AppSpacing.md)
        .padding(.trailing, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
        }
    }
    
    // MARK: - Components
    
    private var selectButton: some View {
        Button {
            HapticService.selection()
            onSelect()
        } label: {
            HStack {
                Text(level.title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.primaryBlue)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var infoButton: some View {
        Button {
            onInfo()
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColors.secondaryText)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}
