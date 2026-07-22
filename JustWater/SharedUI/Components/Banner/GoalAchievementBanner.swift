//
//  GoalAchievementBanner.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import SwiftUI

struct GoalAchievementBanner: View {

    // MARK: - Environment

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Body

    var body: some View {
        Text(String(localized: "goal_achievement.banner.message"))
            .font(AppTypography.body)
            .foregroundStyle(AppColors.primaryBlue)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(.regularMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(Color.primary.opacity(borderOpacity), lineWidth: 1)
            }
            .shadow(
                color: Color.black.opacity(shadowOpacity),
                radius: 10,
                x: 0,
                y: 4
            )
            .frame(maxWidth: 420)
            .accessibilityElement(children: .combine)
    }

    // MARK: - Style

    private var borderOpacity: Double {
        colorScheme == .dark ? 0.18 : 0.10
    }

    private var shadowOpacity: Double {
        colorScheme == .dark ? 0.22 : 0.12
    }
}

private struct GoalAchievementBannerModifier: ViewModifier {

    // MARK: - State

    @State private var isPresented = false
    @State private var isVisible = false
    @State private var dismissTask: Task<Void, Never>?

    // MARK: - Properties

    let trigger: UUID?

    // MARK: - Body

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isPresented {
                    GoalAchievementBanner()
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.sm)
                        .offset(y: isVisible ? 0 : -24)
                        .opacity(isVisible ? 1 : 0)
                        .allowsHitTesting(false)
                }
            }
            .onChange(of: trigger) { _, newValue in
                guard newValue != nil else { return }
                showBanner()
            }
            .onDisappear {
                dismissTask?.cancel()
            }
    }

    // MARK: - Helpers

    private func showBanner() {
        dismissTask?.cancel()
        isPresented = true

        withAnimation(.easeOut(duration: 0.25)) {
            isVisible = true
        }

        dismissTask = Task { @MainActor in
            do {
                try await Task.sleep(for: .seconds(3.5))
            } catch {
                return
            }

            withAnimation(.easeIn(duration: 0.3)) {
                isVisible = false
            }

            do {
                try await Task.sleep(for: .milliseconds(300))
            } catch {
                return
            }

            guard !Task.isCancelled,
                  !isVisible
            else {
                return
            }

            isPresented = false
            dismissTask = nil
        }
    }
}

extension View {

    func goalAchievementBanner(
        trigger: UUID?
    ) -> some View {
        modifier(
            GoalAchievementBannerModifier(
                trigger: trigger
            )
        )
    }
}
