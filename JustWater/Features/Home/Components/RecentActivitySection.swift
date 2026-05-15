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
            Text("Recent Activity")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            if entries.isEmpty {
                emptyState
            } else {
                GlassCard {
                    VStack(spacing: AppSpacing.md) {
                        ForEach(Array(entries.prefix(5))) { entry in
                            entryRow(entry)
                                .transition(
                                    .asymmetric(
                                        insertion: .opacity,
                                        removal: .opacity.combined(with: .scale(scale: 0.96))
                                    )
                                )
                        }
                    }
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.9),
                        value: entries.map(\.id)
                    )
                }
            }
        }
    }
    
    private var emptyState: some View {
        GlassCard {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "drop")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppColors.primaryBlue)
                
                Text("No water added yet")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("Your recent activity will appear here after your first drink.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func entryRow(_ entry: WaterEntry) -> some View {
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

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()
        
        RecentActivitySection(
            entries: [],
            onDelete: { _ in }
        )
        .padding(AppSpacing.lg)
    }
}
