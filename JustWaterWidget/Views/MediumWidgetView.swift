//
//  MediumWidgetView.swift
//  JustWaterWidgetExtension
//
//  Created by сонный on 10.06.2026.
//

import SwiftUI

struct MediumWidgetView: View {
    
    // MARK: - Properties
    
    let entry: JustWaterWidgetEntry
    
    // MARK: - Private Properties
    
    private let palette = JustWaterWidgetPalette()
    private let volumeFormatter = WidgetVolumeFormatter()
    
    private var snapshot: WidgetHydrationSnapshot {
        entry.snapshot.normalizedForToday()
    }
    
    private var measurementUnit: MeasurementUnit {
        MeasurementUnit(
            rawValue: snapshot.measurementUnitRawValue
        ) ?? .milliliters
    }
    
    private var percentageText: String {
        "\(snapshot.percentage)%"
    }
    
    private var consumedText: String {
        volumeFormatter.string(
            fromMilliliters: snapshot.consumedWater,
            unit: measurementUnit
        )
    }
    
    private var goalText: String {
        volumeFormatter.string(
            fromMilliliters: snapshot.dailyGoal,
            unit: measurementUnit
        )
    }
    
    private var remainingText: String {
        if snapshot.isGoalCompleted {
            return String(localized: "widget.goal_completed")
        }
        
        let remainingVolume = volumeFormatter.string(
            fromMilliliters: snapshot.remainingWater,
            unit: measurementUnit
        )
        
        return "\(String(localized: "widget.remaining.prefix")) \(remainingVolume)"
    }
    
    private var goalPrefix: String {
        String(localized: "widget.goal.prefix")
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            background
            
            content
        }
    }
    
    // MARK: - Components
    
    private var content: some View {
        HStack(alignment: .center, spacing: 14) {
            textContent
            
            Spacer(minLength: 4)
            
            WidgetLargeProgressRing(
                progress: snapshot.cappedCompletionRate,
                percentageText: percentageText,
                palette: palette
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
        .padding(.top, 22)
        .padding(.leading, 18)
        .padding(.trailing, 22)
        .padding(.bottom, 16)
    }
    
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            title
            
            VStack(alignment: .leading, spacing: 2) {
                Text(consumedText)
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text("\(goalPrefix) \(goalText)")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            
            Text(remainingText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(palette.accentText.opacity(0.88))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(
            maxHeight: .infinity,
            alignment: .center
        )
    }
    
    private var title: some View {
        Text("JustWater")
            .font(.system(size: 21, weight: .bold, design: .rounded))
            .foregroundStyle(palette.primaryText)
            .lineLimit(1)
    }
    
    private var background: some View {
        Rectangle()
            .fill(palette.background)
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(palette.accentGlow)
                    .frame(width: 120, height: 120)
                    .blur(radius: 36)
                    .offset(x: 28, y: -36)
            }
            .overlay(alignment: .bottomLeading) {
                Circle()
                    .fill(palette.secondaryGlow)
                    .frame(width: 120, height: 120)
                    .blur(radius: 38)
                    .offset(x: -34, y: 34)
            }
    }
}
