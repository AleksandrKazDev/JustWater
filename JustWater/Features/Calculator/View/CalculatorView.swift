//
//  CalculatorView.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import SwiftUI

struct CalculatorView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var viewModel = CalculatorViewModel()
    
    @State private var selectedActivityInfo: ActivityLevel?
    
    @State private var isRecommendationAlertPresented = false
    
    // MARK: - Actions
    
    let onComplete: (Int) -> Void
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppSpacing.xl) {
                header
                
                weightInput
                
                genderPicker
                
                activityPicker
                
                calculateButton
                
                if let recommendedGoal = viewModel.recommendedGoal {
                    recommendedGoalSection(goal: recommendedGoal)
                }
                
                customGoalSection
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
        .sheet(item: $selectedActivityInfo) { level in
            activityInfoSheet(level)
        }
        .alert(
            "Recommended Goal",
            isPresented: $isRecommendationAlertPresented
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let recommendedGoal = viewModel.recommendedGoal {
                Text("\(recommendedGoal) ml per day")
            }
        }
        .navigationTitle("Water Goal")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    private var header: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Water Goal")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text(
                "Get a personalized daily hydration recommendation."
            )
            .font(AppTypography.body)
            .foregroundStyle(AppColors.secondaryText)
            .multilineTextAlignment(.center)
        }
    }
    
    private var weightInput: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Weight (kg)")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            TextField(
                "Enter your weight",
                text: $viewModel.weightText
            )
            .keyboardType(.numberPad)
            .padding(AppSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
            }
            .onChange(
                of: viewModel.weightText
            ) { _, newValue in
                viewModel.updateWeightText(newValue)
            }
        }
    }
    
    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Gender")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            HStack(spacing: AppSpacing.sm) {
                ForEach(Gender.allCases) { gender in
                    Button {
                        viewModel.selectGender(gender)
                    } label: {
                        Text(gender.title)
                            .font(AppTypography.body)
                            .foregroundStyle(
                                viewModel.gender == gender
                                ? .white
                                : AppColors.primaryText
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background {
                                RoundedRectangle(
                                    cornerRadius: AppRadius.lg
                                )
                                .fill(
                                    viewModel.gender == gender
                                    ? AppColors.primaryBlue
                                    : AppColors.cardBackground
                                )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var activityPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Activity Level")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(ActivityLevel.allCases) { level in
                    activityButton(level)
                }
            }
        }
    }
    
    private func activityButton(
        _ level: ActivityLevel
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                viewModel.selectActivityLevel(level)
            } label: {
                HStack {
                    Text(level.title)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Spacer()
                    
                    if viewModel.activityLevel == level {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.primaryBlue)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Button {
                selectedActivityInfo = level
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.secondaryText)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, AppSpacing.md)
        .padding(.trailing, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
        }
    }
    
    private var calculateButton: some View {
        PrimaryButton(
            title: "Calculate Recommendation",
            systemImage: "function"
        ) {
            viewModel.calculateGoal()
            
            if viewModel.recommendedGoal != nil {
                isRecommendationAlertPresented = true
            }
        }
    }
    
    private func recommendedGoalSection(
        goal: Int
    ) -> some View {
        GlassCard {
            VStack(spacing: AppSpacing.md) {
                Text("Recommended Goal")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("\(goal) ml")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primaryText)
                
                PrimaryButton(
                    title: "Use Recommended Goal",
                    systemImage: "checkmark"
                ) {
                    onComplete(goal)
                    dismiss()
                }
            }
        }
    }
    
    private var customGoalSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Custom Goal")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            HStack(spacing: AppSpacing.sm) {
                TextField(
                    "1 - 10000",
                    text: $viewModel.customGoalText
                )
                .keyboardType(.numberPad)
                .onChange(
                    of: viewModel.customGoalText
                ) { _, newValue in
                    viewModel.updateCustomGoalText(newValue)
                }
                
                Text("ml")
                    .font(AppTypography.body)
                    .foregroundStyle(
                        AppColors.secondaryText
                    )
            }
            .padding(AppSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
            }
            
            if let customGoal = viewModel.customGoal {
                PrimaryButton(
                    title: "Use Custom Goal",
                    systemImage: "slider.horizontal.3"
                ) {
                    onComplete(customGoal)
                    dismiss()
                }
            }
        }
    }
    
    private func activityInfoSheet(
        _ level: ActivityLevel
    ) -> some View {
        VStack(spacing: AppSpacing.lg) {
            Text(level.title)
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text(level.description)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(AppSpacing.xl)
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview

//#Preview {
//    CalculatorView { _ in }
//}
