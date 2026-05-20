//
//  GlassCard.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(AppSpacing.lg)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .fill(AppColors.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 12)
            }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        GlassCard {
            VStack(spacing: AppSpacing.sm) {
                Text("JustWater")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("Glass card preview")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
        .padding(AppSpacing.lg)
    }
}
