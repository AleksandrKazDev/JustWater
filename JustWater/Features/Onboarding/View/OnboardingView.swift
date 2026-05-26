//
//  OnboardingView.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    
    // MARK: - Environment
    
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppBackground()
            
            currentStep
                .transition(stepTransition)
        }
        .animation(
            reduceMotion
            ? nil
            : .spring(response: 0.45, dampingFraction: 0.9),
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
            Spacer(minLength: AppSpacing.lg)
            
            OnboardingHeroMark(style: .drop)
            
            VStack(spacing: AppSpacing.sm) {
                Text("JustWater")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                
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
            
            stepIndicator
            
            Spacer(minLength: AppSpacing.lg)
            
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
            Spacer(minLength: AppSpacing.lg)
            
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
                VStack(spacing: 0) {
                    OnboardingBenefitRow(
                        title: "Track your progress",
                        subtitle: "See your daily intake at a glance.",
                        systemImage: "drop.fill"
                    )
                    .padding(.vertical, AppSpacing.sm)
                    
                    Divider()
                        .opacity(0.28)
                    
                    OnboardingBenefitRow(
                        title: "Review your history",
                        subtitle: "Understand your hydration over time.",
                        systemImage: "chart.xyaxis.line"
                    )
                    .padding(.vertical, AppSpacing.sm)
                    
                    Divider()
                        .opacity(0.28)
                    
                    OnboardingBenefitRow(
                        title: "Gentle reminders",
                        subtitle: "Stay on track with gentle reminders.",
                        systemImage: "bell"
                    )
                    .padding(.vertical, AppSpacing.sm)
                }
            }
            
            stepIndicator
            
            Spacer(minLength: AppSpacing.lg)
            
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
        CalculatorView(
            showsHeaderTitle: true
        ) { goal in
            updateDailyGoal(goal)
            coordinator.showResultStep()
        }
    }
    
    private var resultStep: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer(minLength: AppSpacing.lg)
            
            OnboardingHeroMark(style: .success)
            
            VStack(spacing: AppSpacing.sm) {
                Text("\(AppSettingsStorage.dailyGoal) ml")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                
                Text("Your daily goal is ready.")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("You can always adjust it later in Settings.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
            }
            
            stepIndicator
            
            Spacer(minLength: AppSpacing.lg)
            
            PrimaryButton(
                title: "Start Tracking",
                systemImage: "checkmark"
            ) {
                coordinator.completeOnboarding()
            }
        }
        .padding(AppSpacing.lg)
    }
    
    private var stepIndicator: some View {
        OnboardingStepIndicator(
            currentIndex: coordinator.onboardingStep.index,
            totalCount: OnboardingStep.totalCount
        )
    }
    
    private var stepTransition: AnyTransition {
        guard !reduceMotion else {
            return .opacity
        }
        
        return .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        )
    }
    
    // MARK: - Actions
    
    @MainActor
    private func updateDailyGoal(
        _ goal: Int
    ) {
        do {
            let dailyGoalUpdateService = AppFactory.makeDailyGoalUpdateService(
                context: modelContext
            )
            
            try dailyGoalUpdateService.updateDailyGoal(goal)
        } catch {
            print("Failed to update daily goal from OnboardingView: \(error)")
        }
    }
}
