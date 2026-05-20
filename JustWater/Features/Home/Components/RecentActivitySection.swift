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
    let onOpenHistory: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Recent Activity")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            if entries.isEmpty {
                emptyState
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onOpenHistory()
                    }
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
                .contentShape(Rectangle())
                .onTapGesture {
                    onOpenHistory()
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
        HStack(spacing: AppSpacing.sm) {
            DrinkIconView(drinkType: entry.drinkType)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.amount) ml")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                
                Text(entry.drinkType.title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
            
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
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
    }}

//#Preview {
//    ZStack {
//        AppColors.background
//            .ignoresSafeArea()
//        
//        RecentActivitySection(
//            entries: [],
//            onDelete: { _ in }
//        )
//        .padding(AppSpacing.lg)
//    }
//}
