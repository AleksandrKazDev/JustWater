//
//  UndoBanner.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct UndoBanner: View {

    // MARK: - Environment

    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Properties
    
    let message: String
    let isVisible: Bool
    let onUndo: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                Button("Undo") {
                    HapticService.selection()
                    onUndo()
                }
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryBlue)
            }
            .padding(AppSpacing.md)
            .background {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .fill(.regularMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(Color.primary.opacity(borderOpacity), lineWidth: 1)
            }
            .shadow(
                color: Color.black.opacity(shadowOpacity),
                radius: 10,
                x: 0,
                y: 4
            )
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
            .opacity(isVisible ? 1 : 0)
            .allowsHitTesting(isVisible)
        }
    }

    // MARK: - Style

    private var borderOpacity: Double {
        colorScheme == .dark ? 0.18 : 0.10
    }

    private var shadowOpacity: Double {
        colorScheme == .dark ? 0.22 : 0.12
    }
}
