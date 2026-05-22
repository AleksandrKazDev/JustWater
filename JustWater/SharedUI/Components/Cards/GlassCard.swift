//
//  GlassCard.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    
    // MARK: - Properties
    
    private let content: Content
    
    // MARK: - Initializer
    
    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }
    
    // MARK: - Body
    
    var body: some View {
        content
            .padding(AppSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .fill(AppColors.glassFill)
                    .background {
                        RoundedRectangle(cornerRadius: AppRadius.xl)
                            .fill(.ultraThinMaterial)
                            .opacity(0.45)
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .stroke(AppColors.glassStroke, lineWidth: 1)
            }
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: AppRadius.xl)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.glassHighlight.opacity(0.70),
                                AppColors.glassHighlight.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(
                color: AppColors.blueGlow.opacity(0.08),
                radius: 22,
                x: 0,
                y: 12
            )
    }
}
