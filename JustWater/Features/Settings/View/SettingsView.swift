//
//  SettingsView.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - State
    
    @State private var viewModel = AppFactory.makeSettingsViewModel()
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    header
                    
                    dailyGoalSection
                    
                    appearanceSection
                    
                    preferencesSection
                    
                    remindersSection
                    
                    appInfoSection
                }
                .padding(AppSpacing.lg)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.reload()
        }
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
                sectionTitle("Daily Goal")
                
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("\(viewModel.dailyGoal) ml")
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.primaryText)
                        
                        Text("Your current daily hydration target.")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    NavigationLink {
                        CalculatorView { goal in
                            viewModel.updateDailyGoal(goal)
                        }
                    } label: {
                        pillButtonTitle("Change")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var appearanceSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                sectionTitle("Appearance")
                
                Picker(
                    "Appearance",
                    selection: Binding(
                        get: {
                            viewModel.appearanceMode
                        },
                        set: { mode in
                            viewModel.updateAppearanceMode(mode)
                        }
                    )
                ) {
                    ForEach(AppAppearanceMode.allCases) { mode in
                        Text(mode.title)
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
    private var preferencesSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                sectionTitle("Preferences")
                
                Toggle(
                    isOn: Binding(
                        get: {
                            viewModel.isHapticsEnabled
                        },
                        set: { isEnabled in
                            viewModel.updateHapticsEnabled(isEnabled)
                        }
                    )
                ) {
                    settingsLabel(
                        title: "Haptics",
                        subtitle: "Tactile feedback for actions.",
                        systemImage: "waveform"
                    )
                }
                .tint(AppColors.primaryBlue)
                
                Divider()
                    .opacity(0.35)
                
                settingsRow(
                    title: "Units",
                    value: viewModel.measurementUnit.title,
                    systemImage: "ruler"
                )
            }
        }
    }
    
    private var remindersSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                sectionTitle("Reminders")
                
                settingsRow(
                    title: "Hydration Reminders",
                    value: "Coming soon",
                    systemImage: "bell"
                )
            }
        }
    }
    
    private var appInfoSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                sectionTitle("App")
                
                settingsRow(
                    title: "About",
                    value: "JustWater",
                    systemImage: "drop"
                )
                
                Divider()
                    .opacity(0.35)
                
                Text("JustWater is designed for general wellness tracking. It is not medical advice.")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private func sectionTitle(
        _ title: String
    ) -> some View {
        Text(title)
            .font(AppTypography.headline)
            .foregroundStyle(AppColors.primaryText)
    }
    
    private func pillButtonTitle(
        _ title: String
    ) -> some View {
        Text(title)
            .font(AppTypography.caption)
            .foregroundStyle(AppColors.primaryBlue)
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 34)
            .background {
                Capsule()
                    .fill(AppColors.lightBlue.opacity(0.28))
            }
    }
    
    private func settingsRow(
        title: String,
        value: String,
        systemImage: String
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            settingsIcon(systemImage)
            
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            Text(value)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
    
    private func settingsLabel(
        title: String,
        subtitle: String,
        systemImage: String
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            settingsIcon(systemImage)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                
                Text(subtitle)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }
    
    private func settingsIcon(
        _ systemImage: String
    ) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(AppColors.primaryBlue)
            .frame(width: 32, height: 32)
            .background {
                Circle()
                    .fill(AppColors.lightBlue.opacity(0.28))
            }
    }
}
