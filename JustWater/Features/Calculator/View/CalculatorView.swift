//
//  CalculatorView.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import SwiftUI

struct CalculatorView: View {
    
    // MARK: - State
    
    @State private var viewModel = CalculatorViewModel()
    
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
                    resultCard(goal: recommendedGoal)
                }
            }
            .padding(AppSpacing.lg)
        }
        .background(AppColors.background)
    }
    
    // MARK: - Components
    
    private var header: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Water Goal")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text("Get a personalized daily hydration recommendation.")
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
            
            TextField("Enter your weight", text: $viewModel.weightText)
                .keyboardType(.numberPad)
                .padding(AppSpacing.md)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.cardBackground)
                }
                .onChange(of: viewModel.weightText) { _, newValue in
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
                        viewModel.gender = gender
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
                                RoundedRectangle(cornerRadius: AppRadius.lg)
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
        Button {
            viewModel.activityLevel = level
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
            .padding(AppSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var calculateButton: some View {
        PrimaryButton(
            title: "Calculate Goal",
            systemImage: "drop.fill"
        ) {
            viewModel.calculateGoal()
        }
    }
    
    private func resultCard(goal: Int) -> some View {
        GlassCard {
            VStack(spacing: AppSpacing.sm) {
                Text("\(goal) ml")
                    .font(AppTypography.largeTitle)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("Recommended daily goal")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                
                PrimaryButton(
                    title: "Use This Goal",
                    systemImage: "checkmark"
                ) {
                    onComplete(goal)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CalculatorView { _ in }
}
