//
//  HistoryPeriodPicker.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HistoryPeriodPicker: View {
    
    // MARK: - Properties
    
    let selectedPeriod: HistoryPeriod
    let onSelect: (HistoryPeriod) -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(HistoryPeriod.allCases) { period in
                periodButton(
                    period,
                    isSelected: selectedPeriod == period
                )
            }
        }
    }
    
    // MARK: - Components
    
    private func periodButton(
        _ period: HistoryPeriod,
        isSelected: Bool
    ) -> some View {
        Button {
            HapticService.selection()
            onSelect(period)
        } label: {
            Text(period.title)
                .font(AppTypography.caption)
                .foregroundStyle(
                    isSelected ? .white : AppColors.primaryText
                )
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background {
                    periodBackground(isSelected: isSelected)
                }
                .overlay {
                    periodBorder(isSelected: isSelected)
                }
                .shadow(
                    color: periodShadowColor(isSelected: isSelected),
                    radius: isSelected ? 10 : 6,
                    x: 0,
                    y: isSelected ? 5 : 3
                )
        }
        .buttonStyle(
            PressableScaleButtonStyle(
                scale: 0.97,
                pressedBrightness: -0.02
            )
        )
    }
    
    @ViewBuilder
    private func periodBackground(
        isSelected: Bool
    ) -> some View {
        if isSelected {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.primaryBlue,
                            AppColors.deepBlue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        } else {
            Capsule()
                .fill(AppColors.glassFill)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .opacity(0.28)
                }
        }
    }
    
    private func periodBorder(
        isSelected: Bool
    ) -> some View {
        Capsule()
            .stroke(
                isSelected
                ? .white.opacity(0.22)
                : AppColors.glassStroke.opacity(0.20),
                lineWidth: 1
            )
    }
    
    private func periodShadowColor(
        isSelected: Bool
    ) -> Color {
        isSelected
        ? AppColors.blueGlow.opacity(0.08)
        : AppColors.blueGlow.opacity(0.015)
    }
}
