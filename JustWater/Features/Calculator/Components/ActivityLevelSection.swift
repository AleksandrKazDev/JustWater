//
//  ActivityLevelSection.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct ActivityLevelSection: View {
    
    // MARK: - Properties
    
    let selectedActivityLevel: ActivityLevel
    let onSelect: (ActivityLevel) -> Void
    let onInfo: (ActivityLevel) -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Activity Level")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(ActivityLevel.allCases) { level in
                    ActivityLevelRow(
                        level: level,
                        isSelected: selectedActivityLevel == level,
                        onSelect: {
                            onSelect(level)
                        },
                        onInfo: {
                            onInfo(level)
                        }
                    )
                }
            }
        }
    }
}
