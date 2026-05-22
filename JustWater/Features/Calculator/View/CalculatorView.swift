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
    
    @FocusState private var focusedField: CalculatorFocusedField?
    
    // MARK: - Actions
    
    let onComplete: (Int) -> Void
    
    // MARK: - Types
    
    private enum FieldID {
        case weight
        case customGoal
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    CalculatorHeaderView()
                    
                    WeightInputSection(
                        weightText: $viewModel.weightText,
                        focusedField: $focusedField,
                        onChange: viewModel.updateWeightText
                    )
                    .id(FieldID.weight)
                    
                    GenderPickerSection(
                        selectedGender: viewModel.gender,
                        onSelect: viewModel.selectGender
                    )
                    
                    ActivityLevelSection(
                        selectedActivityLevel: viewModel.activityLevel,
                        onSelect: viewModel.selectActivityLevel,
                        onInfo: { level in
                            selectedActivityInfo = level
                        }
                    )
                    
                    calculateButton
                    
                    if let recommendedGoal = viewModel.recommendedGoal {
                        RecommendedGoalSection(
                            goal: recommendedGoal,
                            onUse: {
                                onComplete(recommendedGoal)
                                dismiss()
                            }
                        )
                    }
                    
                    CustomGoalSection(
                        customGoalText: $viewModel.customGoalText,
                        focusedField: $focusedField,
                        customGoal: viewModel.customGoal,
                        onTextChange: viewModel.updateCustomGoalText,
                        onUse: { goal in
                            focusedField = nil
                            onComplete(goal)
                            dismiss()
                        }
                    )
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

