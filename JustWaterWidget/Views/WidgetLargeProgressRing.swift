//
//  WidgetLargeProgressRing.swift
//  JustWaterWidgetExtension
//
//  Created by сонный on 10.06.2026.
//

import SwiftUI

struct WidgetLargeProgressRing: View {
    
    // MARK: - Properties
    
    let progress: Double
    let percentageText: String
    let palette: JustWaterWidgetPalette
    
    // MARK: - Private Properties
    
    private var cappedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            outerGlow
            
            track
            
            progressArc
            
            innerCircle
            
            VStack(spacing: 2) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(palette.accentText)
                
                Text(percentageText)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(width: 94, height: 94)
    }
    
    // MARK: - Components
    
    private var outerGlow: some View {
        Circle()
            .fill(palette.accentGlow)
            .blur(radius: 16)
            .opacity(0.85)
    }
    
    private var track: some View {
        Circle()
            .stroke(
                palette.secondaryText.opacity(0.10),
                lineWidth: 8.5
            )
    }
    
    private var progressArc: some View {
        Circle()
            .trim(from: 0, to: cappedProgress)
            .stroke(
                AngularGradient(
                    colors: [
                        palette.accentText.opacity(0.85),
                        palette.accentText,
                        palette.accentText.opacity(0.85)
                    ],
                    center: .center
                ),
                style: StrokeStyle(
                    lineWidth: 8,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
    }
    
    private var innerCircle: some View {
        Circle()
            .fill(palette.background)
            .frame(width: 68, height: 68)
            .overlay {
                Circle()
                    .stroke(
                        palette.primaryText.opacity(0.04),
                        lineWidth: 1
                    )
            }
    }
}
