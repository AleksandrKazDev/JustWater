//
//  OnboardingHeroMark.swift
//  JustWater
//
//  Created by сонный on 23.05.2026.
//

import SwiftUI

struct OnboardingHeroMark: View {
    
    // MARK: - Types
    
    enum Style {
        case drop
        case success
    }
    
    // MARK: - Properties
    
    let style: Style
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            ambientShape
            
            glassDisc
            
            content
        }
        .frame(width: 210, height: 210)
        .accessibilityHidden(true)
    }
    
    // MARK: - Components
    
    private var ambientShape: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        AppColors.blueGlow.opacity(colorScheme == .dark ? 0.12 : 0.08),
                        AppColors.blueGlow.opacity(colorScheme == .dark ? 0.04 : 0.03),
                        .clear
                    ],
                    center: .center,
                    startRadius: 18,
                    endRadius: 106
                )
            )
            .frame(width: 210, height: 210)
            .blur(radius: colorScheme == .dark ? 2 : 1)
    }
    
    private var glassDisc: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: discColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 158, height: 158)
            .overlay {
                Circle()
                    .stroke(
                        outerStrokeGradient,
                        lineWidth: colorScheme == .dark ? 1.1 : 1.4
                    )
            }
            .overlay {
                Circle()
                    .stroke(
                        innerStrokeColor,
                        lineWidth: 0.7
                    )
                    .padding(6)
            }
            .shadow(
                color: discShadowColor,
                radius: colorScheme == .dark ? 18 : 22,
                x: 0,
                y: 12
            )
    }
    
    @ViewBuilder
    private var content: some View {
        switch style {
        case .drop:
            dropContent
            
        case .success:
            successContent
        }
    }
    
    private var dropContent: some View {
        Image(systemName: "drop.fill")
            .font(.system(size: 50, weight: .semibold))
            .foregroundStyle(iconGradient)
            .shadow(
                color: iconShadowColor,
                radius: 10,
                x: 0,
                y: 5
            )
    }
    
    private var successContent: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(iconGradient)
            .shadow(
                color: iconShadowColor.opacity(0.8),
                radius: 8,
                x: 0,
                y: 4
            )
    }
    
    // MARK: - Styling
    
    private var discColors: [Color] {
        switch colorScheme {
        case .dark:
            return [
                AppColors.cardBackground.opacity(0.92),
                AppColors.glassFill.opacity(0.66)
            ]
            
        default:
            return [
                Color.white.opacity(0.98),
                AppColors.lightBlue.opacity(0.68)
            ]
        }
    }
    
    private var outerStrokeGradient: LinearGradient {
        LinearGradient(
            colors: [
                AppColors.primaryBlue.opacity(colorScheme == .dark ? 0.16 : 0.32),
                AppColors.glassHighlight.opacity(colorScheme == .dark ? 0.18 : 0.64),
                AppColors.primaryBlue.opacity(colorScheme == .dark ? 0.08 : 0.24)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var innerStrokeColor: Color {
        Color.white.opacity(colorScheme == .dark ? 0.04 : 0.20)
    }
    
    private var discShadowColor: Color {
        colorScheme == .dark
        ? AppColors.blueGlow.opacity(0.14)
        : AppColors.primaryBlue.opacity(0.20)
    }
    
    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: [
                AppColors.lightBlue,
                AppColors.primaryBlue
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var iconShadowColor: Color {
        AppColors.primaryBlue.opacity(colorScheme == .dark ? 0.24 : 0.16)
    }
}
