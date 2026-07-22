//
//  BackupPreviewView.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import SwiftUI

struct BackupPreviewView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let preview: BackupImportPreview
    let mergeResult: MergeRestoreResult?
    let isRestoring: Bool
    @Binding var restoreError: BackupRestoreError?
    let onMerge: () -> Void
    let onDone: () -> Void

    // MARK: - State

    @State private var isMergeConfirmationPresented = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        if let mergeResult {
                            mergeResultContent(
                                mergeResult
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
                if mergeResult == nil {
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

            if isRestoring {
                restoreProgress
            } else {
                PrimaryButton(
                    title: String(localized: "common.continue"),
                    systemImage: "arrow.right"
                ) {
                    isMergeConfirmationPresented = true
                }
            }
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

    private var restoreProgress: some View {
        HStack(spacing: AppSpacing.sm) {
            ProgressView()
                .tint(AppColors.primaryBlue)

            Text(String(localized: "settings.backup.merge.progress"))
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
        String(
            localized: mergeResult == nil
            ? "settings.backup.preview.title"
            : "settings.backup.merge.result.title"
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
