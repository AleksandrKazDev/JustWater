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
            AppBackground()
            
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
                
                Text("\(viewModel.dailyGoal) ml")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                
                HStack(alignment: .center, spacing: AppSpacing.md) {
                    Text("Your daily hydration target.")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    
                    Spacer(minLength: AppSpacing.sm)
                    
                    NavigationLink {
                        CalculatorView { goal in
                            viewModel.updateDailyGoal(goal)
                        }
                    } label: {
                        SettingsPillButton(title: "Change")
                            .frame(minWidth: 108)
                    }
                    .buttonStyle(
                        PressableScaleButtonStyle(
                            scale: 0.96,
                            pressedBrightness: -0.02
                        )
                    )
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
                            HapticService.selection()
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
                .buttonStyle(
                    PressableScaleButtonStyle(
                        scale: 0.985,
                        pressedBrightness: -0.015
                    )
                )
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
            .buttonStyle(
                PressableScaleButtonStyle(
                    scale: 0.96,
                    pressedBrightness: -0.02
                )
            )
        }
        .padding(AppSpacing.md)
        .background {
            RoundedRectangle(cornerRadius: AppRadius.md)
                .fill(AppColors.glassFill)
                .background {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(.ultraThinMaterial)
                        .opacity(0.26)
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(
                    AppColors.glassStroke.opacity(0.18),
                    lineWidth: 1
                )
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
