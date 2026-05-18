//
//  OnboardingView.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import SwiftUI

struct OnboardingView: View {
    
    // MARK: - Environment
    
    @Environment(AppCoordinator.self) private var coordinator
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            switch coordinator.onboardingStep {
            case .welcome:
                welcomeStep
                
            case .calculator:
                calculatorStep
                
            case .result:
                resultStep
            }
        }
    }
    
    // MARK: - Components
    
    private var welcomeStep: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Welcome to JustWater")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text("Build a simple daily hydration habit.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
            
            PrimaryButton(
                title: "Continue",
                systemImage: "arrow.right"
            ) {
                coordinator.showCalculatorStep()
            }
        }
        .padding(AppSpacing.lg)
    }
    
    private var calculatorStep: some View {
        CalculatorView { goal in
            AppSettingsStorage.dailyGoal = goal
            coordinator.showResultStep()
        }
    }
//    private var calculatorStep: some View {
//        VStack(spacing: AppSpacing.lg) {
//            Text("Water Goal")
//                .font(AppTypography.title)
//                .foregroundStyle(AppColors.primaryText)
//            
//            Text("We’ll help you estimate your daily water goal.")
//                .font(AppTypography.body)
//                .foregroundStyle(AppColors.secondaryText)
//                .multilineTextAlignment(.center)
//            
//            PrimaryButton(
//                title: "Calculate",
//                systemImage: "target"
//            ) {
//                coordinator.showResultStep()
//            }
//        }
//        .padding(AppSpacing.lg)
//    }
    
    private var resultStep: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("\(AppSettingsStorage.dailyGoal) ml")
                .font(AppTypography.largeTitle)
                .foregroundStyle(AppColors.primaryText)
            
            Text("Your daily hydration goal is ready.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
            
            PrimaryButton(
                title: "Start Tracking",
                systemImage: "checkmark"
            ) {
                coordinator.completeOnboarding()
            }
        }
        .padding(AppSpacing.lg)
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
        .environment(AppCoordinator())
}
