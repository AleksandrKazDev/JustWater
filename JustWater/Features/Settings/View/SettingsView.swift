//
//  SettingsView.swift
//  JustWater
//
//  Created by сонный on 18.05.2026.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            Text("Settings")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

//#Preview {
//    SettingsView()
//}
