//
//  HistoryPeriodNavigation.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HistoryPeriodNavigation: View {
    
    // MARK: - Properties
    
    let title: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onTapTitle: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                HapticService.selection()
                onPrevious()
            } label: {
                navigationIcon("chevron.left")
            }
            .buttonStyle(
                PressableScaleButtonStyle(
                    scale: 0.94,
                    pressedBrightness: -0.02
                )
            )
            
            Spacer()
            
            Button {
                HapticService.selection()
                onTapTitle()
            } label: {
                Text(title)
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(
                PressableScaleButtonStyle(
                    scale: 0.98,
                    pressedBrightness: -0.015
                )
            )
            
            Spacer()
            
            Button {
                HapticService.selection()
                onNext()
            } label: {
                navigationIcon("chevron.right")
            }
            .buttonStyle(
                PressableScaleButtonStyle(
                    scale: 0.94,
                    pressedBrightness: -0.02
                )
            )
        }
    }
    
    // MARK: - Components
    
    private func navigationIcon(
        _ systemImage: String
    ) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(AppColors.primaryText)
            .frame(width: 46, height: 46)
            .background {
                Circle()
                    .fill(AppColors.glassFill)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.32)
                    }
            }
            .overlay {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.glassHighlight.opacity(0.52),
                                AppColors.glassStroke.opacity(0.16)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
//            .shadow(
//                color: AppColors.blueGlow.opacity(0.05),
//                radius: 10,
//                x: 0,
//                y: 5
//            )
            .shadow(
                color: AppColors.blueGlow.opacity(0.02),
                radius: 4,
                x: 0,
                y: 2
            )
    }
}
