//
//  WidgetProgressRing.swift
//  JustWaterWidgetExtension
//
//  Created by сонный on 10.06.2026.
//

import SwiftUI

struct WidgetProgressRing: View {
    
    // MARK: - Properties
    
    let progress: Double
    let palette: JustWaterWidgetPalette
    
    // MARK: - Private Properties
    
    private var cappedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            track
            
            progressArc
            
            icon
        }
        .frame(width: 44, height: 44)
    }
    
    // MARK: - Components
    
    private var track: some View {
        Circle()
            .stroke(
                palette.secondaryText.opacity(0.16),
                lineWidth: 5
            )
    }
    
    private var progressArc: some View {
        Circle()
            .trim(from: 0, to: cappedProgress)
            .stroke(
                AngularGradient(
                    colors: [
                        palette.accentText.opacity(0.72),
                        palette.accentText,
                        palette.accentText.opacity(0.72)
                    ],
                    center: .center
                ),
                style: StrokeStyle(
                    lineWidth: 5,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(-90))
    }
    
    private var icon: some View {
        Image(systemName: "drop.fill")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(palette.accentText)
    }
}
