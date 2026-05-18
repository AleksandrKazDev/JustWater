//
//  File.swift
//  JustWater
//
//  Created by сонный on 11.05.2026.
//

import Foundation

@Observable
final class AppCoordinator {
    
    // MARK: - Properties
    
    var flow: AppFlow
    var onboardingStep: OnboardingStep = .welcome
    
    // MARK: - Initializer
    
    init() {
        flow = AppSettingsStorage.hasCompletedOnboarding ? .main : .onboarding
    }
    
    // MARK: - Public Methods
    
    func completeOnboarding() {
        AppSettingsStorage.hasCompletedOnboarding = true
        flow = .main
    }
    
    func showCalculatorStep() {
        onboardingStep = .calculator
    }

    func showResultStep() {
        onboardingStep = .result
    }
    
    func resetOnboarding() {
        AppSettingsStorage.hasCompletedOnboarding = false
        
        onboardingStep = .welcome
        flow = .onboarding
    }
}
