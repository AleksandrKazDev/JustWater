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
    
    // MARK: - Focus
    
    @FocusState private var focusedField: FocusedField?
    
    // MARK: - Actions
    
    let onComplete: (Int) -> Void
    
    // MARK: - Types
    
    private enum FocusedField {
        case weight
        case customGoal
    }
    
    private enum FieldID {
        case weight
        case customGoal
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    header
                    
                    weightInput
                        .id(FieldID.weight)
                    
                    genderPicker
                    
                    activityPicker
                    
                    calculateButton
                    
                    if let recommendedGoal = viewModel.recommendedGoal {
                        recommendedGoalSection(goal: recommendedGoal)
                    }
                    
                    customGoalSection
                        .id(FieldID.customGoal)
                }
                .padding(AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
            .scrollDismissesKeyboard(.interactively)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .onChange(of: focusedField) { _, newValue in
                guard let newValue else { return }
                
                withAnimation(.easeInOut(duration: 0.25)) {
                    switch newValue {
                    case .weight:
                        proxy.scrollTo(FieldID.weight, anchor: .center)
                        
                    case .customGoal:
                        proxy.scrollTo(FieldID.customGoal, anchor: .center)
                    }
                }
            }
        }
        .background(AppColors.background)
        .sheet(item: $selectedActivityInfo) { level in
            activityInfoSheet(level)
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
            
            TextField(
                "Enter your weight",
                text: $viewModel.weightText
            )
            .focused($focusedField, equals: .weight)
            .keyboardType(.numberPad)
            .font(AppTypography.body)
            .foregroundStyle(AppColors.primaryText)
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
                        HapticService.selection()
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
                HapticService.selection()
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
            focusedField = nil
            HapticService.selection()
            viewModel.calculateGoal()
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
                    HapticService.success()
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
            
            VStack(spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.sm) {
                    TextField(
                        "1 - 10000",
                        text: $viewModel.customGoalText
                    )
                    .focused($focusedField, equals: .customGoal)
                    .keyboardType(.numberPad)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .onChange(of: viewModel.customGoalText) { _, newValue in
                        viewModel.updateCustomGoalText(newValue)
                    }
                    
                    Text("ml")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }
                
                if let customGoal = viewModel.customGoal {
                    Button {
                        focusedField = nil
                        HapticService.success()
                        onComplete(customGoal)
                        dismiss()
                    } label: {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text("Use Custom Goal")
                                .font(AppTypography.body)
                        }
                        .foregroundStyle(AppColors.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background {
                            Capsule()
                                .fill(AppColors.lightBlue.opacity(0.28))
                        }
                    }
                    .buttonStyle(.plain)
                    .transition(
                        .opacity.combined(
                            with: .move(edge: .top)
                        )
                    )
                }
            }
            .padding(AppSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
            }
            .animation(
                .spring(response: 0.35, dampingFraction: 0.9),
                value: viewModel.customGoal
            )
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
