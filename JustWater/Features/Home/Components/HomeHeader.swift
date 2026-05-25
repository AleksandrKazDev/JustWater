//
//  HomeHeader.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI
import SwiftData

struct HomeHeader: View {
    
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Properties
    
    let todayTitle: String
    let onResetOnboarding: () -> Void
    let onGoalUpdated: () -> Void
    
    // MARK: - State
    
    @GestureState private var isMenuPressed = false
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            titleSection
            
            Spacer()
            
            menuButton
        }
    }
    
    // MARK: - Components
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Today, \(todayTitle)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
            
            Text("JustWater")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
        }
    }
    
    private var menuButton: some View {
        Menu {
            NavigationLink {
                HistoryView()
            } label: {
                Label(
                    "History",
                    systemImage: "clock.arrow.circlepath"
                )
            }
            
            NavigationLink {
                CalculatorView { goal in
                    updateDailyGoal(goal)
                }
            } label: {
                Label(
                    "Goal Calculator",
                    systemImage: "target"
                )
            }
            
            NavigationLink {
                SettingsView()
            } label: {
                Label(
                    "Settings",
                    systemImage: "gearshape"
                )
            }
            
            #if DEBUG
            Divider()
            
            Button(role: .destructive) {
                onResetOnboarding()
            } label: {
                Label(
                    "Reset Onboarding",
                    systemImage: "arrow.counterclockwise"
                )
            }
            #endif
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColors.secondaryText)
                .frame(width: 46, height: 46)
                .background {
                    Circle()
                        .fill(AppColors.glassFill)
                        .background {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .opacity(0.35)
                        }
                }
                .overlay {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppColors.glassHighlight.opacity(0.55),
                                    AppColors.glassStroke.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(
                    color: AppColors.blueGlow.opacity(0.06),
                    radius: 12,
                    x: 0,
                    y: 6
                )
                .scaleEffect(isMenuPressed ? 0.94 : 1)
                .brightness(isMenuPressed ? -0.03 : 0)
                .animation(
                    .spring(response: 0.22, dampingFraction: 0.82),
                    value: isMenuPressed
                )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isMenuPressed) { _, state, _ in
                    state = true
                }
        )
    }
    
    // MARK: - Actions
    
    @MainActor
    private func updateDailyGoal(
        _ goal: Int
    ) {
        do {
            let goalStorageService = WaterGoalStorageService(
                context: modelContext
            )
            
            try goalStorageService.updateGoal(
                goal,
                effectiveDate: Date.now
            )
            
            AppSettingsStorage.dailyGoal = goal
            onGoalUpdated()
        } catch {
            print("Failed to update daily goal from HomeHeader: \(error)")
        }
    }
}
