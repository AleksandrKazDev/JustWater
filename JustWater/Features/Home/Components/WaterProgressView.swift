//
//  WaterProgressView.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

struct WaterProgressView: View {
    
    let progress: Double
    
    @State private var wavePhase: CGFloat = 0
    @State private var secondaryWavePhase: CGFloat = .pi
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    var body: some View {
        ZStack {
            backgroundCircle
            
            waterFill
            
            progressRing
            
            centerContent
        }
        .frame(width: 220, height: 220)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hydration progress")
        .accessibilityValue("\(Int(clampedProgress * 100)) percent")
    }
    
    private var backgroundCircle: some View {
        Circle()
            .fill(AppColors.cardBackground)
            .overlay {
                Circle()
                    .stroke(AppColors.border, lineWidth: 1)
            }
            .shadow(
                color: AppColors.primaryBlue.opacity(0.16),
                radius: 24,
                x: 0,
                y: 14
            )
    }
    
    private var waterFill: some View {
        ZStack {
            WaterWaveShape(
                progress: clampedProgress,
                waveHeight: 8,
                phase: wavePhase
            )
            .fill(
                LinearGradient(
                    colors: [
                        AppColors.lightBlue.opacity(0.48),
                        AppColors.primaryBlue.opacity(0.28)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            WaterWaveShape(
                progress: clampedProgress,
                waveHeight: 5,
                phase: secondaryWavePhase
            )
            .fill(
                LinearGradient(
                    colors: [
                        AppColors.primaryBlue.opacity(0.24),
                        AppColors.deepBlue.opacity(0.18)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .clipShape(Circle())
        .padding(18)
        .onAppear {
            withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 4
            }
            
            withAnimation(.linear(duration: 3.6).repeatForever(autoreverses: false)) {
                secondaryWavePhase = .pi * 5
            }
        }
    }
    
    private var progressRing: some View {
        Circle()
            .trim(from: 0, to: clampedProgress)
            .stroke(
                LinearGradient(
                    colors: [
                        AppColors.lightBlue,
                        AppColors.primaryBlue,
                        AppColors.deepBlue
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(
                    lineWidth: 18,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .animation(
                .spring(response: 0.7, dampingFraction: 0.85),
                value: clampedProgress
            )
    }
    
    private var centerContent: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("\(Int(clampedProgress * 100))%")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(AppColors.deepBlue)
            
            Text("hydrated")
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        WaterProgressView(progress: 0.6)
    }
}
