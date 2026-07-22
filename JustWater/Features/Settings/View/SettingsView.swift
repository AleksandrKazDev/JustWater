//
//  SettingsView.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import SwiftUI
import SwiftData
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Properties
    
    let onHydrationSettingsChanged: () -> Void
    
    // MARK: - Initializer
    
    init(
        onHydrationSettingsChanged: @escaping () -> Void = {}
    ) {
        self.onHydrationSettingsChanged = onHydrationSettingsChanged
    }
    
    // MARK: - Body
    
    var body: some View {
        SettingsContentView(
            viewModel: AppFactory.makeSettingsViewModel(
                context: modelContext
            ),
            onHydrationSettingsChanged: onHydrationSettingsChanged
        )
    }
}

private struct SettingsContentView: View {
    
    // MARK: - State

    @State private var viewModel: SettingsViewModel
    @State private var backupDocument: BackupFileDocument?
    @State private var backupFileName = ""
    @State private var isBackupExporterPresented = false
    @State private var isBackupImporterPresented = false
    @State private var isBackupInfoPresented = false
    @State private var isPreparingBackup = false
    @State private var backupAlert: BackupAlert?

    private let onHydrationSettingsChanged: () -> Void

    // MARK: - Types

    private enum BackupAlert: String, Identifiable {
        case backupSaved
        case backupCreationFailed
        case backupSaveFailed
        case backupSelectionFailed
        case backupFileSelected

        var id: String {
            rawValue
        }
    }
    
    // MARK: - Initializer
    
    init(
        viewModel: SettingsViewModel,
        onHydrationSettingsChanged: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: viewModel
        )
        self.onHydrationSettingsChanged = onHydrationSettingsChanged
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: AppSpacing.lg) {
                    header
                    
                    dailyGoalSection(viewModel)
                    
                    appearanceSection(viewModel)
                    
                    preferencesSection(viewModel)
                    
                    remindersSection(viewModel)
                    
                    healthSection(viewModel)
                    
                    backupSection(viewModel)

                    appInfoSection
                }
                .padding(AppSpacing.lg)
            }
        }
        .navigationTitle(String(localized: "Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.reloadIfNeeded()
        }
        .sheet(isPresented: $isBackupInfoPresented) {
            backupInfoSheet
        }
        .fileExporter(
            isPresented: $isBackupExporterPresented,
            document: backupDocument,
            contentType: .json,
            defaultFilename: backupFileName
        ) { result in
            handleBackupExportResult(
                result,
                viewModel: viewModel
            )
        }
        .fileImporter(
            isPresented: $isBackupImporterPresented,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleBackupImportSelection(
                result,
                viewModel: viewModel
            )
        }
        .alert(item: $backupAlert) { alert in
            alertContent(for: alert)
        }
    }
    
    // MARK: - Components
    
    private var header: some View {
        Text(String(localized: "Manage your hydration preferences."))
            .font(AppTypography.body)
            .foregroundStyle(AppColors.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private func dailyGoalSection(
        _ viewModel: SettingsViewModel
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SettingsSectionTitle(title: String(localized: "settings.daily_goal"))
                
                Text(
                    formattedVolume(
                        milliliters: viewModel.dailyGoal,
                        unit: viewModel.measurementUnit
                    )
                )
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                
                HStack(alignment: .center, spacing: AppSpacing.md) {
                    Text(String(localized: "Your daily hydration target."))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    
                    Spacer(minLength: AppSpacing.sm)
                    
                    NavigationLink {
                        CalculatorView { goal in
                            viewModel.updateDailyGoal(goal)
                            onHydrationSettingsChanged()
                        }
                    } label: {
                        SettingsPillButton(title: String(localized: "Change"))
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
    
    private func appearanceSection(
        _ viewModel: SettingsViewModel
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SettingsSectionTitle(title: String(localized: "Appearance"))
                
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
    
    private func preferencesSection(
        _ viewModel: SettingsViewModel
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SettingsSectionTitle(title: String(localized: "Preferences"))
                
                Toggle(
                    isOn: Binding(
                        get: {
                            viewModel.isHapticsEnabled
                        },
                        set: { isEnabled in
                            viewModel.updateHapticsEnabled(isEnabled)
                            
                            if isEnabled {
                                HapticService.selection()
                            }
                        }
                    )
                ) {
                    SettingsLabel(
                        title: String(localized: "Haptics"),
                        subtitle: String(localized: "Tactile feedback for app actions."),
                        systemImage: "waveform"
                    )
                }
                .tint(AppColors.primaryBlue)
                
                Divider()
                    .opacity(0.35)
                
                Button {
                    HapticService.selection()
                    openAppSettings()
                } label: {
                    HStack(spacing: AppSpacing.md) {
                        SettingsLabel(
                            title: String(localized: "Language"),
                            subtitle: String(localized: "Change the app language in iPhone Settings."),
                            systemImage: "globe"
                        )
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.secondaryText.opacity(0.65))
                    }
                }
                .buttonStyle(.plain)
                
                Divider()
                    .opacity(0.35)
                
                Button {
                    HapticService.selection()
                    viewModel.updateMeasurementUnit(
                        viewModel.measurementUnit.toggled
                    )
                    onHydrationSettingsChanged()
                } label: {
                    HStack(spacing: AppSpacing.md) {
                        SettingsLabel(
                            title: String(localized: "Units"),
                            subtitle: String(localized: "Choose how water amounts are displayed."),
                            systemImage: "ruler"
                        )
                        
                        Spacer()
                        
                        Text(viewModel.measurementUnit.shortTitle)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func remindersSection(
        _ viewModel: SettingsViewModel
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SettingsSectionTitle(title: String(localized: "Reminders"))
                
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
                        title: String(localized: "Hydration Reminders"),
                        subtitle: String(localized: "Gentle reminders during your day."),
                        systemImage: "bell"
                    )
                }
                .tint(AppColors.primaryBlue)
                
                if viewModel.isNotificationPermissionDenied {
                    permissionDeniedView(viewModel)
                }
                
                Divider()
                    .opacity(0.35)
                
                reminderScheduleSection(viewModel)
                    .disabled(!viewModel.areRemindersEnabled)
                    .opacity(viewModel.areRemindersEnabled ? 1 : 0.45)
                
//#if DEBUG
//                Divider()
//                    .opacity(0.35)
//                
//                Button {
//                    Task {
//                        await viewModel.scheduleTestNotificationInFiveSeconds()
//                    }
//                } label: {
//                    SettingsRow(
//                        title: String(localized: "Test Notification"),
//                        value: String(localized: "5 seconds"),
//                        systemImage: "bell.badge"
//                    )
//                }
//                .buttonStyle(
//                    PressableScaleButtonStyle(
//                        scale: 0.985,
//                        pressedBrightness: -0.015
//                    )
//                )
//#endif
            }
        }
    }
    
    private func healthSection(
        _ viewModel: SettingsViewModel
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SettingsSectionTitle(title: String(localized: "Apple Health"))
                
                Toggle(
                    isOn: Binding(
                        get: {
                            viewModel.isHealthSyncEnabled
                        },
                        set: { isEnabled in
                            HapticService.selection()
                            viewModel.setHealthSyncEnabled(isEnabled)
                        }
                    )
                ) {
                    SettingsLabel(
                        title: String(localized: "Sync Water Intake"),
                        subtitle: String(localized: "Save your logged water intake to Apple Health."),
                        systemImage: "heart.text.square"
                    )
                }
                .tint(AppColors.primaryBlue)
                
                Text(String(localized: "JustWater only writes water entries to Apple Health when this option is enabled."))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func backupSection(
        _ viewModel: SettingsViewModel
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    SettingsSectionTitle(
                        title: String(localized: "settings.backup.title")
                    )

                    Spacer()

                    Button {
                        isBackupInfoPresented = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(AppColors.secondaryText)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        String(localized: "settings.backup.info.accessibility_label")
                    )
                }

                Text(String(localized: "settings.backup.description"))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Divider()
                    .opacity(0.35)

                backupActionRow(
                    title: String(localized: "settings.backup.create"),
                    systemImage: "square.and.arrow.up"
                ) {
                    prepareBackupExport(viewModel)
                }
                .disabled(isPreparingBackup)

                Divider()
                    .opacity(0.35)

                backupActionRow(
                    title: String(localized: "settings.backup.restore"),
                    systemImage: "arrow.clockwise"
                ) {
                    isBackupImporterPresented = true
                }
            }
        }
    }

    private func backupActionRow(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            HapticService.selection()
            action()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                SettingsIconView(systemImage: systemImage)

                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: AppSpacing.sm)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.secondaryText.opacity(0.65))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(
            PressableScaleButtonStyle(
                scale: 0.985,
                pressedBrightness: -0.015
            )
        )
    }

    private var backupInfoSheet: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text(String(localized: "settings.backup.instructions.title"))
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)

                Text(String(localized: "settings.backup.instructions.body"))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background {
            AppColors.background
                .ignoresSafeArea()
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppColors.background)
    }
    
    private func permissionDeniedView(
        _ viewModel: SettingsViewModel
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(String(localized: "Notifications are disabled in iPhone Settings."))
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            
            Button {
                viewModel.openNotificationSettings()
            } label: {
                SettingsPillButton(title: String(localized: "Open Settings"))
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
    
    private func reminderScheduleSection(
        _ viewModel: SettingsViewModel
    ) -> some View {
        VStack(spacing: AppSpacing.md) {
            reminderHourPicker(
                title: String(localized: "Start Time"),
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
                title: String(localized: "End Time"),
                selectedHour: Binding(
                    get: {
                        viewModel.reminderEndHour
                    },
                    set: { hour in
                        viewModel.updateReminderEndHour(hour)
                    }
                )
            )
            
            frequencyPicker(viewModel)
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
    
    private func frequencyPicker(
        _ viewModel: SettingsViewModel
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(String(localized: "Frequency"))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            Picker(
                String(localized: "Frequency"),
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
                SettingsSectionTitle(title: String(localized: "App"))
                
                SettingsRow(
                    title: "JustWater",
                    value: appVersion,
                    systemImage: "drop"
                )
                
                Divider()
                    .opacity(0.35)
                
                SettingsLabel(
                    title: String(localized: "Wellness Tracking"),
                    subtitle: String(localized: "Track your daily water intake, review your history, and adjust your goal over time."),
                    systemImage: "heart.text.square"
                )
                
                Divider()
                    .opacity(0.35)
                
                SettingsLabel(
                    title: String(localized: "Local Data"),
                    subtitle: String(localized: "Your hydration entries and goal history are stored locally on this device."),
                    systemImage: "lock"
                )
                
                Divider()
                    .opacity(0.35)
                
                Text(String(localized: "JustWater is designed for general wellness tracking and is not medical advice."))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Helpers

    private func prepareBackupExport(
        _ viewModel: SettingsViewModel
    ) {
        guard !isPreparingBackup else { return }

        isPreparingBackup = true
        defer {
            isPreparingBackup = false
        }

        do {
            let result = try viewModel.createBackup()
            backupDocument = BackupFileDocument(
                data: result.data
            )
            backupFileName = result.suggestedFileName
            isBackupExporterPresented = true
        } catch {
            backupAlert = .backupCreationFailed
        }
    }

    private func handleBackupExportResult(
        _ result: Result<URL, Error>,
        viewModel: SettingsViewModel
    ) {
        defer {
            backupDocument = nil
        }

        switch result {
        case .success:
            HapticService.success()
            backupAlert = .backupSaved

        case let .failure(error):
            guard !isUserCancellation(error) else { return }

            viewModel.reportBackupFileSaveError(error)
            backupAlert = .backupSaveFailed
        }
    }

    private func handleBackupImportSelection(
        _ result: Result<[URL], Error>,
        viewModel: SettingsViewModel
    ) {
        switch result {
        case let .success(urls):
            guard let url = urls.first else { return }

            handleSelectedBackupFile(url)

        case let .failure(error):
            guard !isUserCancellation(error) else { return }

            viewModel.reportBackupFileSelectionError(error)
            backupAlert = .backupSelectionFailed
        }
    }

    private func handleSelectedBackupFile(
        _ url: URL
    ) {
        let isAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if isAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }

        backupAlert = .backupFileSelected
    }

    private func isUserCancellation(
        _ error: Error
    ) -> Bool {
        let cocoaError = error as NSError

        return cocoaError.domain == NSCocoaErrorDomain
        && cocoaError.code == NSUserCancelledError
    }

    private func alertContent(
        for alert: BackupAlert
    ) -> Alert {
        let title: String
        let message: String

        switch alert {
        case .backupSaved:
            title = String(localized: "settings.backup.alert.saved.title")
            message = String(localized: "settings.backup.alert.saved.message")

        case .backupCreationFailed:
            title = String(localized: "settings.backup.alert.creation_failed.title")
            message = String(localized: "settings.backup.alert.try_again.message")

        case .backupSaveFailed:
            title = String(localized: "settings.backup.alert.save_failed.title")
            message = String(localized: "settings.backup.alert.try_again.message")

        case .backupSelectionFailed:
            title = String(localized: "settings.backup.alert.selection_failed.title")
            message = String(localized: "settings.backup.alert.try_again.message")

        case .backupFileSelected:
            title = String(localized: "settings.backup.alert.file_selected.title")
            message = String(localized: "settings.backup.alert.file_selected.message")
        }

        return Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(
                Text(String(localized: "common.done"))
            )
        )
    }
    
    private func formattedHour(
        _ hour: Int
    ) -> String {
        String(format: "%02d:00", hour)
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        switch (version, build) {
        case let (.some(version), .some(build)):
            return "v\(version) (\(build))"
            
        case let (.some(version), .none):
            return "v\(version)"
            
        default:
            return String(localized: "Version unknown")
        }
    }
    
    private func openAppSettings() {
        guard let url = URL(
            string: UIApplication.openSettingsURLString
        ) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    private func formattedVolume(
        milliliters: Int,
        unit: MeasurementUnit
    ) -> String {
        MeasurementUnitFormatter()
            .string(
                fromMilliliters: milliliters,
                unit: unit
            )
    }
}
