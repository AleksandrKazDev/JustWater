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
                
                Toggle(
                    isOn: Binding(
                        get: {
                            viewModel.areRemindersEnabled
                        },
                        set: { isEnabled in
                            viewModel.setRemindersEnabled(isEnabled)
                        }
                    )
                ) {
                    SettingsLabel(
                        title: "Hydration Reminders",
                        subtitle: "Gentle reminders during your day.",
                        systemImage: "bell"
                    )
                }
                .tint(AppColors.primaryBlue)
                
                if viewModel.isNotificationPermissionDenied {
                    permissionDeniedView
                }
                
                Divider()
                    .opacity(0.35)
                
                reminderScheduleSection
                    .disabled(!viewModel.areRemindersEnabled)
                    .opacity(viewModel.areRemindersEnabled ? 1 : 0.45)
                
#if DEBUG
Divider()
    .opacity(0.35)

Button {
    Task {
        await NotificationService.scheduleTestNotificationInFiveSeconds()
    }
} label: {
    SettingsRow(
        title: "Test Notification",
        value: "5 seconds",
        systemImage: "bell.badge"
    )
}
.buttonStyle(.plain)
#endif
            }
        }
    }
    
    private var permissionDeniedView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Notifications are disabled in iPhone Settings.")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            
            Button {
                viewModel.openNotificationSettings()
            } label: {
                SettingsPillButton(title: "Open Settings")
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColors.cardBackground)
        }
    }
    
    private var reminderScheduleSection: some View {
        VStack(spacing: AppSpacing.md) {
            reminderHourPicker(
                title: "Start Time",
                selectedHour: Binding(
                    get: {
                        viewModel.reminderStartHour
                    },
                    set: { hour in
                        viewModel.updateReminderStartHour(hour)
                    }
                )
            )
            
            reminderHourPicker(
                title: "End Time",
                selectedHour: Binding(
                    get: {
                        viewModel.reminderEndHour
                    },
                    set: { hour in
                        viewModel.updateReminderEndHour(hour)
                    }
                )
            )
            
            frequencyPicker
        }
    }
    
    private func reminderHourPicker(
        title: String,
        selectedHour: Binding<Int>
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            Picker(
                title,
                selection: selectedHour
            ) {
                ForEach(0..<24, id: \.self) { hour in
                    Text(formattedHour(hour))
                        .tag(hour)
                }
            }
            .pickerStyle(.menu)
            .tint(AppColors.primaryBlue)
        }
    }
    
    private var frequencyPicker: some View {
        HStack(spacing: AppSpacing.sm) {
            Text("Frequency")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            Picker(
                "Frequency",
                selection: Binding(
                    get: {
                        viewModel.reminderFrequency
                    },
                    set: { frequency in
                        viewModel.updateReminderFrequency(frequency)
                    }
                )
            ) {
                ForEach(ReminderFrequency.allCases) { frequency in
                    Text(frequency.title)
                        .tag(frequency)
                }
            }
            .pickerStyle(.menu)
            .tint(AppColors.primaryBlue)
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
  // MARK: - Helpers
    private func formattedHour(
        _ hour: Int
    ) -> String {
        String(format: "%02d:00", hour)
    }
}
