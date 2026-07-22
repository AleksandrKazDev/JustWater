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
    @State private var isPreparingBackup = false
    @State private var isPreparingBackupImport = false
    @State private var backupImportTask: Task<Void, Never>?
    @State private var backupImportRequestID: UUID?
    @State private var backupRestoreTask: Task<Void, Never>?
    @State private var backupRestoreRequestID: UUID?
    @State private var preparedBackupImport: PreparedBackupImport?
    @State private var backupImportPreview: BackupImportPreview?
    @State private var backupRestoreResult: BackupRestorePresentationResult?
    @State private var backupRestoreError: BackupRestoreError?
    @State private var isRestoringBackup = false
    @State private var backupSheet: BackupSheet?
    @State private var backupAlert: BackupAlert?

    private let onHydrationSettingsChanged: () -> Void

    // MARK: - Types

    private enum BackupAlert: String, Identifiable {
        case backupSaved
        case backupCreationFailed
        case backupSaveFailed
        case backupSelectionFailed
        case backupCannotReadFile
        case backupFileTooLarge
        case backupMalformed
        case backupInvalidFormat
        case backupUnsupportedVersion
        case backupInvalidData

        var id: String {
            rawValue
        }
    }

    private enum BackupSheet: String, Identifiable {
        case info
        case preview

        var id: String {
            rawValue
        }
    }

    private enum BackupRestoreOperation {
        case merge
        case replace
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
        .onDisappear {
            cancelBackupImportPreparation()
            cancelBackupRestore()
        }
        .sheet(
            item: $backupSheet,
            onDismiss: {
                handleBackupSheetDismissed()
            }
        ) { sheet in
            switch sheet {
            case .info:
                backupInfoSheet

            case .preview:
                if let backupImportPreview {
                    BackupPreviewView(
                        preview: backupImportPreview,
                        restoreResult: backupRestoreResult,
                        isRestoring: isRestoringBackup,
                        restoreError: $backupRestoreError,
                        onMerge: {
                            guard let preparedBackupImport else { return }

                            startBackupRestore(
                                preparedBackupImport,
                                operation: .merge,
                                viewModel: viewModel
                            )
                        },
                        onReplace: {
                            guard let preparedBackupImport else { return }

                            startBackupRestore(
                                preparedBackupImport,
                                operation: .replace,
                                viewModel: viewModel
                            )
                        },
                        onDone: {
                            backupSheet = nil
                        }
                    )
                }
            }
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
                        guard !isPreparingBackupImport else { return }
                        backupSheet = .info
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
                    .disabled(isPreparingBackupImport)
                    .opacity(isPreparingBackupImport ? 0.45 : 1)
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
                .disabled(
                    isPreparingBackup
                    || isPreparingBackupImport
                )

                Divider()
                    .opacity(0.35)

                backupActionRow(
                    title: isPreparingBackupImport
                    ? String(localized: "settings.backup.import.loading")
                    : String(localized: "settings.backup.restore"),
                    systemImage: "arrow.clockwise",
                    isLoading: isPreparingBackupImport
                ) {
                    isBackupImporterPresented = true
                }
                .disabled(
                    isPreparingBackup
                    || isPreparingBackupImport
                )
            }
        }
    }

    private func backupActionRow(
        title: String,
        systemImage: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            HapticService.selection()
            action()
        } label: {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(AppColors.primaryBlue)
                        .frame(width: 40, height: 40)
                } else {
                    SettingsIconView(systemImage: systemImage)
                }

                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: AppSpacing.sm)

                if !isLoading {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.secondaryText.opacity(0.65))
                }
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

            handleSelectedBackupFile(
                url,
                viewModel: viewModel
            )

        case let .failure(error):
            guard !isUserCancellation(error) else { return }

            viewModel.reportBackupFileSelectionError(error)
            backupAlert = .backupSelectionFailed
        }
    }

    private func handleSelectedBackupFile(
        _ url: URL,
        viewModel: SettingsViewModel
    ) {
        guard !isPreparingBackupImport else { return }

        cancelBackupImportPreparation()

        let requestID = UUID()
        backupImportRequestID = requestID
        isPreparingBackupImport = true

        backupImportTask = Task { @MainActor in
            defer {
                if backupImportRequestID == requestID {
                    backupImportTask = nil
                    backupImportRequestID = nil
                    isPreparingBackupImport = false
                }
            }

            do {
                let preparedImport = try await viewModel.prepareBackupImport(
                    from: url
                )

                guard !Task.isCancelled,
                      backupImportRequestID == requestID,
                      backupSheet == nil
                else {
                    return
                }

                preparedBackupImport = preparedImport
                backupImportPreview = preparedImport.preview
                HapticService.success()
                backupSheet = .preview
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled,
                      backupImportRequestID == requestID
                else {
                    return
                }

                backupAlert = backupAlert(
                    for: error
                )
            }
        }
    }

    private func cancelBackupImportPreparation() {
        backupImportRequestID = nil
        backupImportTask?.cancel()
        backupImportTask = nil
        isPreparingBackupImport = false
        preparedBackupImport = nil
        backupImportPreview = nil
    }

    private func startBackupRestore(
        _ preparedImport: PreparedBackupImport,
        operation: BackupRestoreOperation,
        viewModel: SettingsViewModel
    ) {
        guard !isRestoringBackup else { return }

        cancelBackupRestore()

        let requestID = UUID()
        backupRestoreRequestID = requestID
        isRestoringBackup = true

        backupRestoreTask = Task { @MainActor in
            defer {
                if backupRestoreRequestID == requestID {
                    backupRestoreTask = nil
                    backupRestoreRequestID = nil
                    isRestoringBackup = false
                }
            }

            do {
                let result: BackupRestorePresentationResult

                switch operation {
                case .merge:
                    result = .merge(
                        try await viewModel.mergeBackup(
                            preparedImport
                        )
                    )

                case .replace:
                    result = .replace(
                        try await viewModel.replaceBackup(
                            preparedImport
                        )
                    )
                }

                guard !Task.isCancelled,
                      backupRestoreRequestID == requestID,
                      backupSheet == .preview
                else {
                    return
                }

                preparedBackupImport = nil
                backupRestoreResult = result
                HapticService.success()
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled,
                      backupRestoreRequestID == requestID
                else {
                    return
                }

                backupRestoreError = error as? BackupRestoreError
                ?? .persistenceFailed
            }
        }
    }

    private func cancelBackupRestore() {
        backupRestoreRequestID = nil
        backupRestoreTask?.cancel()
        backupRestoreTask = nil
        isRestoringBackup = false
        backupRestoreResult = nil
        backupRestoreError = nil
    }

    private func handleBackupSheetDismissed() {
        let didCompleteRestore = backupRestoreResult != nil

        cancelBackupRestore()
        preparedBackupImport = nil
        backupImportPreview = nil

        if didCompleteRestore {
            onHydrationSettingsChanged()
        }
    }

    private func backupAlert(
        for error: Error
    ) -> BackupAlert {
        guard let importError = error as? BackupImportError else {
            return .backupCannotReadFile
        }

        switch importError {
        case .cannotReadFile:
            return .backupCannotReadFile

        case .fileTooLarge:
            return .backupFileTooLarge

        case .malformedBackup:
            return .backupMalformed

        case .invalidFormat:
            return .backupInvalidFormat

        case .unsupportedSchemaVersion:
            return .backupUnsupportedVersion

        case .invalidData:
            return .backupInvalidData
        }
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

        case .backupCannotReadFile:
            title = String(localized: "settings.backup.import_error.cannot_read.title")
            message = String(localized: "settings.backup.import_error.cannot_read.message")

        case .backupFileTooLarge:
            title = String(localized: "settings.backup.import_error.file_too_large.title")
            message = String(localized: "settings.backup.import_error.file_too_large.message")

        case .backupMalformed:
            title = String(localized: "settings.backup.import_error.malformed.title")
            message = String(localized: "settings.backup.import_error.malformed.message")

        case .backupInvalidFormat:
            title = String(localized: "settings.backup.import_error.invalid_format.title")
            message = String(localized: "settings.backup.import_error.invalid_format.message")

        case .backupUnsupportedVersion:
            title = String(localized: "settings.backup.import_error.unsupported_version.title")
            message = String(localized: "settings.backup.import_error.unsupported_version.message")

        case .backupInvalidData:
            title = String(localized: "settings.backup.import_error.invalid_data.title")
            message = String(localized: "settings.backup.import_error.invalid_data.message")
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
