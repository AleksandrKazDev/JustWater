//
//  SettingsView.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    header
                    
                    dailyGoalSection
                    
                    preferencesSection
                    
                    appInfoSection
                }
                .padding(AppSpacing.lg)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Settings")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text("Manage your hydration preferences.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
    
    private var dailyGoalSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Daily Goal")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("\(AppSettingsStorage.dailyGoal) ml")
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.primaryText)
                        
                        Text("Your current daily hydration target.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        CalculatorView { goal in
                            AppSettingsStorage.dailyGoal = goal
                        }
                    } label: {
                        Text("Change")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.primaryBlue)
                            .padding(.horizontal, AppSpacing.md)
                            .frame(height: 34)
                            .background {
                                Capsule()
                                    .fill(AppColors.lightBlue.opacity(0.28))
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var preferencesSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Preferences")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                settingsRow(
                    title: "Units",
                    value: "Milliliters",
                    systemImage: "ruler"
                )
                
                settingsRow(
                    title: "Reminders",
                    value: "Coming soon",
                    systemImage: "bell"
                )
            }
        }
    }
    
    private var appInfoSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("App")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                settingsRow(
                    title: "About",
                    value: "JustWater",
                    systemImage: "drop"
                )
                
                Text("JustWater is designed for general wellness tracking. It is not medical advice.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func settingsRow(
        title: String,
        value: String,
        systemImage: String
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.primaryBlue)
                .frame(width: 32, height: 32)
                .background {
                    Circle()
                        .fill(AppColors.lightBlue.opacity(0.28))
                }
            
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            Text(value)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
}
