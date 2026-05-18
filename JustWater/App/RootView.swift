//
//  RootView.swift
//  JustWater
//
//  Created by сонный on 11.05.2026.
//

import SwiftUI

struct RootView: View {
    
    // MARK: - State
    
    @State private var coordinator = AppCoordinator()
    
    // MARK: - Body
    
    var body: some View {
        switch coordinator.flow {
        case .onboarding:
            OnboardingView()
                .environment(coordinator)
            
        case .main:
            HomeView()
                .environment(coordinator)
        }
    }
    
    // MARK: - Components
    
//    private var onboardingPlaceholder: some View {
//        VStack(spacing: AppSpacing.lg) {
//            Text("Welcome to JustWater")
//                .font(AppTypography.title)
//                .foregroundStyle(AppColors.primaryText)
//            
//            PrimaryButton(
//                title: "Continue",
//                systemImage: "arrow.right"
//            ) {
//                coordinator.completeOnboarding()
//            }
//            .padding(.horizontal, AppSpacing.lg)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(AppColors.background)
//    }
}

// MARK: - Preview

#Preview {
    RootView()
}
