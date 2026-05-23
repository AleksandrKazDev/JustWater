//
//  OnboardingHeroDrop.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

//import SwiftUI
//
//struct OnboardingHeroDrop: View {
//    
//    // MARK: - Body
//    
//    var body: some View {
//        ZStack {
//            ambientGlow
//            
//            glassCircle
//            
//            progressHint
//            
//            Image(systemName: "drop.fill")
//                .font(.system(size: 46, weight: .semibold))
//                .foregroundStyle(
//                    LinearGradient(
//                        colors: [
//                            AppColors.lightBlue.opacity(0.92),
//                            AppColors.primaryBlue.opacity(0.82)
//                        ],
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                )
//                .shadow(
//                    color: AppColors.blueGlow.opacity(0.10),
//                    radius: 8,
//                    x: 0,
//                    y: 4
//                )
//        }
//        .frame(height: 210)
//    }
//    
//    // MARK: - Components
//    
//    private var ambientGlow: some View {
//        Circle()
//            .fill(AppColors.blueGlow.opacity(0.10))
//            .frame(width: 170, height: 170)
//            .blur(radius: 24)
//    }
//    
//    private var glassCircle: some View {
//        Circle()
//            .fill(AppColors.cardBackground.opacity(0.72))
//            .frame(width: 138, height: 138)
//            .overlay {
//                Circle()
//                    .stroke(
//                        LinearGradient(
//                            colors: [
//                                AppColors.glassHighlight.opacity(0.24),
//                                AppColors.glassStroke.opacity(0.10)
//                            ],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        ),
//                        lineWidth: 1
//                    )
//            }
//    }
//    
//    private var progressHint: some View {
//        Circle()
//            .trim(from: 0.08, to: 0.72)
//            .stroke(
//                LinearGradient(
//                    colors: [
//                        AppColors.lightBlue.opacity(0.42),
//                        AppColors.primaryBlue.opacity(0.56)
//                    ],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                ),
//                style: StrokeStyle(
//                    lineWidth: 6,
//                    lineCap: .round
//                )
//            )
//            .frame(width: 160, height: 160)
//            .rotationEffect(.degrees(-92))
//            .opacity(0.72)
//    }
//}
