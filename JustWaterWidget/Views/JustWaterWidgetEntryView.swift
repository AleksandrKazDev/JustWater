//
//  JustWaterWidgetEntryView.swift
//  JustWaterWidgetExtension
//
//  Created by сонный on 10.06.2026.
//

import SwiftUI
import WidgetKit

struct JustWaterWidgetEntryView: View {
    
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
    
    private var isEmptyToday: Bool {
        snapshot.consumedWater == 0
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
    
    private var goalPrefix: String {
        String(localized: "widget.goal.prefix")
    }
    
    private var startTodayText: String {
        String(localized: "widget.start_today")
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            background
            
            content
        }
        .widgetURL(URL(string: "justwater://home"))
    }
    
    // MARK: - Components
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 6) {
            title
            
            progressSection
            
            if isEmptyToday {
                emptyStateText
            }
            
            volumeSection
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(.top, 16)
        .padding(.leading, 16)
        .padding(.trailing, 15)
        .padding(.bottom, 12)
    }
    
    private var title: some View {
        Text("JustWater")
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(palette.primaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var progressSection: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(percentageText)
                .font(.system(size: 34, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Spacer(minLength: 4)
            
            WidgetProgressRing(
                progress: snapshot.cappedCompletionRate,
                palette: palette
            )
        }
        .padding(.top, 6)
    }
    
    private var emptyStateText: some View {
        Text(startTodayText)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(palette.accentText)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
    
    private var volumeSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(consumedText)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(palette.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            
            Text("\(goalPrefix) \(goalText)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(palette.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
    
    private var background: some View {
        Rectangle()
            .fill(palette.background)
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(palette.accentGlow)
                    .frame(width: 62, height: 62)
                    .blur(radius: 24)
                    .offset(x: 18, y: -20)
            }
            .overlay(alignment: .bottomLeading) {
                Circle()
                    .fill(palette.secondaryGlow)
                    .frame(width: 68, height: 68)
                    .blur(radius: 26)
                    .offset(x: -22, y: 24)
            }
    }
}
