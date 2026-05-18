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
            NavigationStack {
                HomeView()
                    .environment(coordinator)
            }
        }
    }
}

// MARK: - Preview

//#Preview {
//    RootView()
//}
