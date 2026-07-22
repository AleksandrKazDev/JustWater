//
//  BackupSettingsSection.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct BackupSettingsFlow<Content: View>: View {

    // MARK: - State

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

    // MARK: - Properties

    let viewModel: SettingsViewModel
    let onHydrationSettingsChanged: () -> Void
    let content: (BackupSettingsSection) -> Content

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
        onHydrationSettingsChanged: @escaping () -> Void,
        @ViewBuilder content: @escaping (BackupSettingsSection) -> Content
    ) {
        self.viewModel = viewModel
        self.onHydrationSettingsChanged = onHydrationSettingsChanged
        self.content = content
    }

    // MARK: - Body

    var body: some View {
        content(backupSection)
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
                                    operation: .merge
                                )
                            },
                            onReplace: {
                                guard let preparedBackupImport else { return }

                                startBackupRestore(
                                    preparedBackupImport,
                                    operation: .replace
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
                handleBackupExportResult(result)
            }
            .fileImporter(
                isPresented: $isBackupImporterPresented,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleBackupImportSelection(result)
            }
            .alert(item: $backupAlert) { alert in
                alertContent(for: alert)
            }
    }

    // MARK: - Components

    private var backupSection: BackupSettingsSection {
        BackupSettingsSection(
            isPreparingBackup: isPreparingBackup,
            isPreparingBackupImport: isPreparingBackupImport,
            onShowInfo: {
                guard !isPreparingBackupImport else { return }
                backupSheet = .info
            },
            onCreateBackup: {
                prepareBackupExport()
            },
            onRestoreBackup: {
                isBackupImporterPresented = true
            }
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

    // MARK: - Helpers

    private func prepareBackupExport() {
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
        _ result: Result<URL, Error>
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
        _ result: Result<[URL], Error>
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
        operation: BackupRestoreOperation
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
}

struct BackupSettingsSection: View {

    // MARK: - Properties

    let isPreparingBackup: Bool
    let isPreparingBackupImport: Bool
    let onShowInfo: () -> Void
    let onCreateBackup: () -> Void
    let onRestoreBackup: () -> Void

    // MARK: - Body

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    SettingsSectionTitle(
                        title: String(localized: "settings.backup.title")
                    )

                    Spacer()

                    Button {
                        onShowInfo()
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
                    systemImage: "square.and.arrow.up",
                    action: onCreateBackup
                )
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
                    isLoading: isPreparingBackupImport,
                    action: onRestoreBackup
                )
                .disabled(
                    isPreparingBackup
                    || isPreparingBackupImport
                )
            }
        }
    }

    // MARK: - Components

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
}
