//
//  BackupPreviewView.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import SwiftUI

enum BackupRestorePresentationResult: Equatable {
    case merge(MergeRestoreResult)
    case replace(ReplaceRestoreResult)
}

struct BackupPreviewView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let preview: BackupImportPreview
    let restoreResult: BackupRestorePresentationResult?
    let isRestoring: Bool
    @Binding var restoreError: BackupRestoreError?
    let onMerge: () -> Void
    let onReplace: () -> Void
    let onDone: () -> Void

    // MARK: - State

    @State private var isMergeConfirmationPresented = false
    @State private var isReplaceConfirmationPresented = false
    @State private var selectedRestoreMode = RestoreMode.merge

    // MARK: - Types

    private enum RestoreMode {
        case merge
        case replace
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        if let restoreResult {
                            restoreResultContent(
                                restoreResult
                            )
                        } else {
                            previewContent
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if restoreResult == nil {
                    ToolbarItem(
                        placement: .cancellationAction
                    ) {
                        Button(String(localized: "common.cancel")) {
                            dismiss()
                        }
                        .disabled(isRestoring)
                    }
                }
            }
            .alert(
                String(localized: "settings.backup.merge.confirmation.title"),
                isPresented: $isMergeConfirmationPresented
            ) {
                Button(String(localized: "common.cancel"), role: .cancel) {}
                Button(String(localized: "settings.backup.merge.confirmation.action")) {
                    onMerge()
                }
            } message: {
                Text(String(localized: "settings.backup.merge.confirmation.message"))
            }
            .alert(
                String(localized: "settings.backup.replace.confirmation.title"),
                isPresented: $isReplaceConfirmationPresented
            ) {
                Button(String(localized: "common.cancel"), role: .cancel) {}
                Button(
                    String(localized: "settings.backup.replace.confirmation.action"),
                    role: .destructive
                ) {
                    onReplace()
                }
            } message: {
                Text(replaceConfirmationMessage)
            }
            .alert(
                restoreErrorTitle,
                isPresented: isRestoreErrorPresented
            ) {
                Button(String(localized: "common.done")) {
                    restoreError = nil
                }
            } message: {
                Text(restoreErrorMessage)
            }
        }
        .interactiveDismissDisabled(isRestoring)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppColors.background)
    }

    // MARK: - Components

    private var previewContent: some View {
        Group {
            Text(String(localized: "settings.backup.preview.description"))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            GlassCard {
                VStack(spacing: AppSpacing.md) {
                    previewRow(
                        title: String(localized: "settings.backup.preview.file_name"),
                        value: preview.fileName,
                        systemImage: "doc"
                    )

                    Divider()
                        .opacity(0.35)

                    previewRow(
                        title: String(localized: "settings.backup.preview.created_at"),
                        value: preview.createdAt.formatted(
                            date: .long,
                            time: .shortened
                        ),
                        systemImage: "calendar"
                    )

                    Divider()
                        .opacity(0.35)

                    previewRow(
                        title: String(localized: "settings.backup.preview.app_version"),
                        value: "\(preview.appVersion) (\(preview.buildNumber))",
                        systemImage: "app.badge"
                    )

                    Divider()
                        .opacity(0.35)

                    previewRow(
                        title: String(localized: "settings.backup.preview.water_entries"),
                        value: preview.waterEntryCount.formatted(),
                        systemImage: "drop"
                    )

                    Divider()
                        .opacity(0.35)

                    previewRow(
                        title: String(localized: "settings.backup.preview.goal_history"),
                        value: preview.goalHistoryCount.formatted(),
                        systemImage: "target"
                    )

                    Divider()
                        .opacity(0.35)

                    previewRow(
                        title: String(localized: "settings.backup.preview.streak_days"),
                        value: preview.streakDayCount.formatted(),
                        systemImage: "flame"
                    )

                    Divider()
                        .opacity(0.35)

                    previewRow(
                        title: String(localized: "settings.backup.preview.file_size"),
                        value: preview.fileSize.formatted(
                            .byteCount(style: .file)
                        ),
                        systemImage: "internaldrive"
                    )
                }
            }

            restoreModePicker

            if isRestoring {
                restoreProgress
            } else {
                PrimaryButton(
                    title: String(localized: "common.continue"),
                    systemImage: "arrow.right"
                ) {
                    switch selectedRestoreMode {
                    case .merge:
                        isMergeConfirmationPresented = true

                    case .replace:
                        isReplaceConfirmationPresented = true
                    }
                }
            }
        }
    }

    private var restoreModePicker: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(String(localized: "settings.backup.restore_mode.title"))
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                restoreModeButton(
                    mode: .merge,
                    title: String(localized: "settings.backup.restore_mode.merge.title"),
                    description: String(localized: "settings.backup.restore_mode.merge.description"),
                    systemImage: "arrow.triangle.merge",
                    isDestructive: false
                )

                Divider()
                    .opacity(0.35)

                restoreModeButton(
                    mode: .replace,
                    title: String(localized: "settings.backup.restore_mode.replace.title"),
                    description: String(localized: "settings.backup.restore_mode.replace.description"),
                    systemImage: "trash",
                    isDestructive: true
                )
            }
        }
        .disabled(isRestoring)
        .opacity(isRestoring ? 0.55 : 1)
    }

    private func restoreModeButton(
        mode: RestoreMode,
        title: String,
        description: String,
        systemImage: String,
        isDestructive: Bool
    ) -> some View {
        let isSelected = selectedRestoreMode == mode
        let accentColor = isDestructive ? Color.red : AppColors.primaryBlue

        return Button {
            selectedRestoreMode = mode
        } label: {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(accentColor)
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.body)
                        .foregroundStyle(
                            isDestructive
                            ? Color.red
                            : AppColors.primaryText
                        )
                        .fixedSize(horizontal: false, vertical: true)

                    Text(description)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: AppSpacing.sm)

                Image(
                    systemName: isSelected
                    ? "checkmark.circle.fill"
                    : "circle"
                )
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(
                    isSelected
                    ? accentColor
                    : AppColors.secondaryText.opacity(0.6)
                )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func restoreResultContent(
        _ result: BackupRestorePresentationResult
    ) -> some View {
        switch result {
        case let .merge(mergeResult):
            mergeResultContent(mergeResult)

        case let .replace(replaceResult):
            replaceResultContent(replaceResult)
        }
    }

    private func mergeResultContent(
        _ result: MergeRestoreResult
    ) -> some View {
        Group {
            Text(
                String(
                    localized: result.hasInsertedData
                    ? "settings.backup.merge.result.description"
                    : "settings.backup.merge.result.up_to_date"
                )
            )
            .font(AppTypography.body)
            .foregroundStyle(AppColors.secondaryText)
            .fixedSize(horizontal: false, vertical: true)

            resultCard(
                title: String(localized: "settings.backup.preview.water_entries"),
                systemImage: "drop",
                counts: result.waterEntries
            )

            resultCard(
                title: String(localized: "settings.backup.preview.goal_history"),
                systemImage: "target",
                counts: result.goalHistory
            )

            resultCard(
                title: String(localized: "settings.backup.preview.streak_days"),
                systemImage: "flame",
                counts: result.streakDays
            )

            PrimaryButton(
                title: String(localized: "common.done"),
                systemImage: "checkmark"
            ) {
                onDone()
            }
        }
    }

    private func replaceResultContent(
        _ result: ReplaceRestoreResult
    ) -> some View {
        Group {
            Text(String(localized: "settings.backup.replace.result.description"))
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            replaceResultCard(
                title: String(localized: "settings.backup.preview.water_entries"),
                systemImage: "drop",
                count: result.restoredEntriesCount
            )

            replaceResultCard(
                title: String(localized: "settings.backup.preview.goal_history"),
                systemImage: "target",
                count: result.restoredGoalsCount
            )

            replaceResultCard(
                title: String(localized: "settings.backup.preview.streak_days"),
                systemImage: "flame",
                count: result.restoredStreakDaysCount
            )

            PrimaryButton(
                title: String(localized: "common.done"),
                systemImage: "checkmark"
            ) {
                onDone()
            }
        }
    }

    private var restoreProgress: some View {
        HStack(spacing: AppSpacing.sm) {
            ProgressView()
                .tint(AppColors.primaryBlue)

            Text(
                String(
                    localized: selectedRestoreMode == .replace
                    ? "settings.backup.replace.progress"
                    : "settings.backup.merge.progress"
                )
            )
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 58)
        .accessibilityElement(children: .combine)
    }

    private func resultCard(
        title: String,
        systemImage: String,
        counts: MergeRestoreCounts
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    SettingsIconView(
                        systemImage: systemImage
                    )

                    Text(title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                resultRow(
                    title: String(localized: "settings.backup.merge.result.added"),
                    value: counts.inserted
                )

                Divider()
                    .opacity(0.35)

                resultRow(
                    title: String(localized: "settings.backup.merge.result.unchanged"),
                    value: counts.unchanged
                )

                Divider()
                    .opacity(0.35)

                resultRow(
                    title: String(localized: "settings.backup.merge.result.conflicts"),
                    value: counts.conflicts
                )
            }
        }
    }

    private func replaceResultCard(
        title: String,
        systemImage: String,
        count: Int
    ) -> some View {
        GlassCard {
            HStack(spacing: AppSpacing.sm) {
                SettingsIconView(
                    systemImage: systemImage
                )

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(String(localized: "settings.backup.replace.result.restored"))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: AppSpacing.sm)

                Text(count.formatted())
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private func resultRow(
        title: String,
        value: Int
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: AppSpacing.sm)

            Text(value.formatted())
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
        }
        .accessibilityElement(children: .combine)
    }

    private func previewRow(
        title: String,
        value: String,
        systemImage: String
    ) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            SettingsIconView(
                systemImage: systemImage
            )

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text(value)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Helpers

    private var navigationTitle: String {
        switch restoreResult {
        case .none:
            return String(localized: "settings.backup.preview.title")

        case .merge:
            return String(localized: "settings.backup.merge.result.title")

        case .replace:
            return String(localized: "settings.backup.replace.result.title")
        }
    }

    private var replaceConfirmationMessage: String {
        let hasHydrationData = preview.waterEntryCount > 0
        || preview.goalHistoryCount > 0
        || preview.streakDayCount > 0

        return String(
            localized: hasHydrationData
            ? "settings.backup.replace.confirmation.message"
            : "settings.backup.replace.confirmation.empty_message"
        )
    }

    private var isRestoreErrorPresented: Binding<Bool> {
        Binding(
            get: {
                restoreError != nil
            },
            set: { isPresented in
                if !isPresented {
                    restoreError = nil
                }
            }
        )
    }

    private var restoreErrorTitle: String {
        switch restoreError {
        case .invalidPreparedBackup:
            return String(localized: "settings.backup.restore_error.invalid.title")

        case .cannotReadCurrentData:
            return String(localized: "settings.backup.restore_error.read.title")

        case .persistenceFailed, .none:
            return String(localized: "settings.backup.restore_error.persistence.title")
        }
    }

    private var restoreErrorMessage: String {
        switch restoreError {
        case .invalidPreparedBackup:
            return String(localized: "settings.backup.restore_error.invalid.message")

        case .cannotReadCurrentData:
            return String(localized: "settings.backup.restore_error.read.message")

        case .persistenceFailed, .none:
            return String(localized: "settings.backup.restore_error.persistence.message")
        }
    }
}
