//
//  AppBackground.swift
//  JustWater
//
//  Created by сонный on 22.05.2026.
//

import SwiftUI

struct AppBackground: View {
    
    // MARK: - Body
    
    var body: some View {
        LinearGradient(
            colors: [
                AppColors.backgroundTop,
                AppColors.backgroundBottom
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(AppColors.blueGlow.opacity(0.16))
                .frame(width: 280, height: 280)
                .blur(radius: 90)
                .offset(x: 110, y: -130)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(AppColors.lightBlue.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 95)
                .offset(x: -120, y: 120)
        }
        .ignoresSafeArea()
    }
}
