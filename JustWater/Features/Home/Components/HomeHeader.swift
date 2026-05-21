//
//  HomeHeader.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HomeHeader: View {
    
    // MARK: - Properties
    
    let todayTitle: String
    let onResetOnboarding: () -> Void
    let onGoalUpdated: () -> Void
    
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
                    AppSettingsStorage.dailyGoal = goal
                    onGoalUpdated()
                }
            } label: {
                Label(
                    "Water Goal",
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
            
            Divider()
            
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
                .frame(width: 44, height: 44)
                .background {
                    Circle()
                        .fill(AppColors.cardBackground)
                }
        }
        .buttonStyle(.plain)
    }
}
