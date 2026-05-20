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
                Button {
                    onSelect(period)
                } label: {
                    Text(period.title)
                        .font(AppTypography.caption)
                        .foregroundStyle(
                            selectedPeriod == period
                            ? .white
                            : AppColors.primaryText
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background {
                            Capsule()
                                .fill(
                                    selectedPeriod == period
                                    ? AppColors.primaryBlue
                                    : AppColors.cardBackground
                                )
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
