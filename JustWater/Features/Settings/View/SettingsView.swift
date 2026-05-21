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
                SettingsSectionTitle(title: "Daily Goal")
                
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
                        SettingsPillButton(title: "Change")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var appearanceSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SettingsSectionTitle(title: "Appearance")
                
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
                SettingsSectionTitle(title: "Preferences")
                
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
                    SettingsLabel(
                        title: "Haptics",
                        subtitle: "Tactile feedback for actions.",
                        systemImage: "waveform"
                    )
                }
                .tint(AppColors.primaryBlue)
                
                Divider()
                    .opacity(0.35)
                
                SettingsRow(
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
                SettingsSectionTitle(title: "Reminders")
                
                SettingsRow(
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
                SettingsSectionTitle(title: "App")
                
                SettingsRow(
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
}
