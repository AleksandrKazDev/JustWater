//
//  SettingsIconView.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import SwiftUI

struct SettingsIconView: View {
    
    // MARK: - Properties
    
    let systemImage: String
    
    // MARK: - Body
    
    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(AppColors.primaryBlue)
            .frame(width: 32, height: 32)
            .background {
                Circle()
                    .fill(AppColors.lightBlue.opacity(0.28))
            }
    }
}
