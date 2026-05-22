//
//  WaterProgressView.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

struct WaterProgressView: View {
    
    // MARK: - Properties
    
    let progress: Double
    let percentage: Int
    
    // MARK: - State
    
    @State private var animatedProgress: Double = 0
    @State private var wavePhase: CGFloat = 0
    @State private var secondaryWavePhase: CGFloat = .pi
    @State private var reflectionOffset: CGFloat = -90
    
    // MARK: - Environment
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Computed Properties
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    private var hydratedTextColor: Color {
        switch colorScheme {
        case .dark:
            return .white.opacity(0.62)
            
        default:
            return AppColors.secondaryText
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            backgroundCircle
            
            waterFill
            
            progressTrack
            
            progressRing
            
            centerContent
        }
        .frame(width: 220, height: 220)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hydration progress")
        .accessibilityValue("\(Int(clampedProgress * 100)) percent")
        .onAppear {
            startAnimations()
        }
        .onChange(of: clampedProgress) { _, newValue in
            withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                animatedProgress = newValue
            }
        }
    }
    
    // MARK: - Components
    
    private var backgroundCircle: some View {
        Circle()
            .fill(AppColors.cardBackground)
            .overlay {
                Circle()
                    .stroke(AppColors.border, lineWidth: 1)
            }
            .shadow(
                color: AppColors.primaryBlue.opacity(
                    colorScheme == .dark ? 0.12 : 0.10
                ),
                radius: 22,
                x: 0,
                y: 12
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
                        AppColors.lightBlue.opacity(
                            colorScheme == .dark ? 0.52 : 0.48
                        ),
                        AppColors.primaryBlue.opacity(
                            colorScheme == .dark ? 0.34 : 0.28
                        )
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
                        AppColors.primaryBlue.opacity(
                            colorScheme == .dark ? 0.24 : 0.22
                        ),
                        AppColors.deepBlue.opacity(
                            colorScheme == .dark ? 0.16 : 0.16
                        )
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            waterReflection
        }
        .clipShape(Circle())
        .padding(18)
    }
    
    private var progressTrack: some View {
        Circle()
            .stroke(
                AppColors.glassFill.opacity(
                    colorScheme == .dark ? 0.16 : 0.48
                ),
                style: StrokeStyle(
                    lineWidth: 18,
                    lineCap: .round
                )
            )
    }
    
    private var progressRing: some View {
        Circle()
            .trim(from: 0, to: animatedProgress)
            .stroke(
                AngularGradient(
                    colors: progressRingColors,
                    center: .center,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(270)
                ),
                style: StrokeStyle(
                    lineWidth: 18,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
            .shadow(
                color: AppColors.blueGlow.opacity(
                    colorScheme == .dark ? 0.10 : 0.06
                ),
                radius: 8,
                x: 0,
                y: 4
            )
    }
    
    private var centerContent: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("\(percentage)%")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.progressText)
                .shadow(
                    color: colorScheme == .dark ? .black.opacity(0.18) : .clear,
                    radius: 6,
                    x: 0,
                    y: 2
                )
            
            Text("hydrated")
                .font(AppTypography.caption)
                .foregroundStyle(hydratedTextColor)
        }
    }
    
    private var waterReflection: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(colorScheme == .dark ? 0.16 : 0.24),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 110, height: 18)
            .rotationEffect(.degrees(-8))
            .offset(x: reflectionOffset, y: -42)
            .blur(radius: 7)
            .blendMode(.screen)
            .opacity(reduceMotion ? 0.18 : 0.45)
    }
    
    // MARK: - Helpers
    
    private var progressRingColors: [Color] {
        switch colorScheme {
        case .dark:
            return [
                AppColors.lightBlue.opacity(0.95),
                AppColors.blueGlow.opacity(0.95),
                AppColors.primaryBlue.opacity(0.90),
                AppColors.lightBlue.opacity(0.95)
            ]
            
        default:
            return [
                AppColors.lightBlue.opacity(0.88),
                AppColors.primaryBlue.opacity(0.94),
                AppColors.deepBlue.opacity(0.82),
                AppColors.lightBlue.opacity(0.88)
            ]
        }
    }
    
    private func startAnimations() {
        animatedProgress = clampedProgress
        
        guard !reduceMotion else {
            return
        }
        
        withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
            wavePhase = .pi * 4
        }
        
        withAnimation(.linear(duration: 3.6).repeatForever(autoreverses: false)) {
            secondaryWavePhase = .pi * 5
        }
        
        withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
            reflectionOffset = 90
        }
    }
}
