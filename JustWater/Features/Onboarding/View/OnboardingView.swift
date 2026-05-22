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
            
            currentStep
                .transition(
                    .asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    )
                )
        }
        .animation(
            .spring(response: 0.45, dampingFraction: 0.9),
            value: coordinator.onboardingStep
        )
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private var currentStep: some View {
        switch coordinator.onboardingStep {
        case .welcome:
            welcomeStep
            
        case .benefits:
            benefitsStep
            
        case .calculator:
            calculatorStep
            
        case .result:
            resultStep
        }
    }
    
    private var welcomeStep: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            OnboardingHeroDrop()
            
            VStack(spacing: AppSpacing.sm) {
                Text("JustWater")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("Build a calmer hydration habit.")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("Track water and other drinks with a clean, simple daily flow.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
            }
            
            OnboardingStepIndicator(
                currentIndex: 0,
                totalCount: 3
            )
            
            Spacer()
            
            PrimaryButton(
                title: "Get Started",
                systemImage: "arrow.right"
            ) {
                coordinator.showBenefitsStep()
            }
        }
        .padding(AppSpacing.lg)
    }
    
    private var benefitsStep: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            VStack(spacing: AppSpacing.sm) {
                Text("Simple by design")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("Everything you need to stay mindful of your hydration, without clutter.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
            }
            
            GlassCard {
                VStack(spacing: AppSpacing.lg) {
                    OnboardingBenefitRow(
                        title: "Track your progress",
                        subtitle: "See your daily intake at a glance.",
                        systemImage: "drop.fill"
                    )
                    
                    OnboardingBenefitRow(
                        title: "Review your history",
                        subtitle: "Understand your hydration over time.",
                        systemImage: "chart.xyaxis.line"
                    )
                    
                    OnboardingBenefitRow(
                        title: "Gentle reminders",
                        subtitle: "Set calm notifications when you need them.",
                        systemImage: "bell"
                    )
                }
            }
            
            OnboardingStepIndicator(
                currentIndex: 1,
                totalCount: 3
            )
            
            Spacer()
            
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
    
    private var resultStep: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppColors.lightBlue.opacity(0.22))
                    .frame(width: 150, height: 150)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(AppColors.primaryBlue)
            }
            
            VStack(spacing: AppSpacing.sm) {
                Text("\(AppSettingsStorage.dailyGoal) ml")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("Your daily goal is ready.")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("You can always adjust it later in Settings.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            OnboardingStepIndicator(
                currentIndex: 2,
                totalCount: 3
            )
            
            Spacer()
            
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
