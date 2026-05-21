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
    @State private var appearanceMode = AppSettingsStorage.appearanceMode
    
    // MARK: - Body
    
    var body: some View {
        Group {
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
        .preferredColorScheme(appearanceMode.colorScheme)
        .onAppear {
            appearanceMode = AppSettingsStorage.appearanceMode
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .appAppearanceDidChange
            )
        ) { _ in
            appearanceMode = AppSettingsStorage.appearanceMode
        }
    }
}
