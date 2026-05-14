//
//  RecentActivitySection.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

struct RecentActivitySection: View {
    
    let entries: [WaterEntry]
    let onDelete: (WaterEntry) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Recent Activity")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Spacer()
            }
            
            GlassCard {
                VStack(spacing: AppSpacing.md) {
                    ForEach(entries.prefix(3)) { entry in
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(AppColors.primaryBlue)
                                .frame(width: 32, height: 32)
                                .background {
                                    Circle()
                                        .fill(AppColors.lightBlue.opacity(0.35))
                                }
                            
                            Text("\(entry.amount) ml")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.primaryText)
                            
                            Spacer()
                            
                            Text(entry.date, style: .time)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.secondaryText)
                            
                            Button {
                                onDelete(entry)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColors.secondaryText)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        RecentActivitySection(
            entries: [
                WaterEntry(amount: 250),
                WaterEntry(amount: 500),
                WaterEntry(amount: 300)
            ],
            onDelete: { _ in }
        )
        .padding(AppSpacing.lg)
    }
}
