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

    // MARK: - State

    @State private var isContinueAlertPresented = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
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

                        PrimaryButton(
                            title: String(localized: "common.continue"),
                            systemImage: "arrow.right"
                        ) {
                            isContinueAlertPresented = true
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle(
                String(localized: "settings.backup.preview.title")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                }
            }
            .alert(
                String(localized: "settings.backup.preview.continue_alert.title"),
                isPresented: $isContinueAlertPresented
            ) {
                Button(String(localized: "common.done")) {}
            } message: {
                Text(String(localized: "settings.backup.preview.continue_alert.message"))
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppColors.background)
    }

    // MARK: - Components

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
}
