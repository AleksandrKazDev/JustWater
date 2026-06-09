//
//  JustWaterWidget.swift
//  JustWaterWidget
//
//  Created by сонный on 09.06.2026.
//

import WidgetKit
import SwiftUI

struct JustWaterWidgetProvider: TimelineProvider {
    
    func placeholder(
        in context: Context
    ) -> JustWaterWidgetEntry {
        JustWaterWidgetEntry(
            date: .now,
            snapshot: .empty
        )
    }
    
    func getSnapshot(
        in context: Context,
        completion: @escaping (JustWaterWidgetEntry) -> Void
    ) {
        completion(
            JustWaterWidgetEntry(
                date: .now,
                snapshot: WidgetSnapshotStorage.load()
            )
        )
    }
    
    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<JustWaterWidgetEntry>) -> Void
    ) {
        let entry = JustWaterWidgetEntry(
            date: .now,
            snapshot: WidgetSnapshotStorage.load()
        )
        
        let nextUpdateDate = Calendar.current.date(
            byAdding: .minute,
            value: 30,
            to: .now
        ) ?? .now.addingTimeInterval(1_800)
        
        completion(
            Timeline(
                entries: [entry],
                policy: .after(nextUpdateDate)
            )
        )
    }
}

struct JustWaterWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetHydrationSnapshot
}

struct JustWaterWidgetEntryView: View {
    
    let entry: JustWaterWidgetEntry
    
    private var measurementUnit: MeasurementUnit {
        MeasurementUnit(
            rawValue: entry.snapshot.measurementUnitRawValue
        ) ?? .milliliters
    }
    
    private var percentageText: String {
        "\(Int(entry.snapshot.completionRate * 100))%"
    }
    
    private var consumedText: String {
        formattedVolume(
            entry.snapshot.consumedWater
        )
    }
    
    private var goalText: String {
        formattedVolume(
            entry.snapshot.dailyGoal
        )
    }
    
    private var goalPrefix: String {
        String(localized: "widget.goal.prefix")
    }
    
    private var unitShortTitle: String {
        switch measurementUnit {
        case .milliliters:
            return "ml"
            
        case .fluidOunces:
            return "fl oz"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("JustWater")
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Spacer(minLength: 4)
            
            Text(percentageText)
                .font(.system(size: 38, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(consumedText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Text("\(goalPrefix) \(goalText)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .leading
        )
        .padding()
        .widgetURL(URL(string: "justwater://home"))
    }
    
    private func formattedVolume(
        _ milliliters: Int
    ) -> String {
        switch measurementUnit {
        case .milliliters:
            let value = MeasurementUnitFormatter()
                .inputString(
                    fromMilliliters: milliliters,
                    unit: .milliliters
                )
            
            return "\(value) \(unitShortTitle)"
            
        case .fluidOunces:
            let value = MeasurementUnitConverter.value(
                fromMilliliters: milliliters,
                unit: .fluidOunces
            )
            
            return "\(Int(value.rounded())) \(unitShortTitle)"
        }
    }
}

struct JustWaterWidget: Widget {
    
    let kind = "JustWaterWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: JustWaterWidgetProvider()
        ) { entry in
            JustWaterWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("JustWater")
        .description(String(localized: "widget.description"))
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    JustWaterWidget()
} timeline: {
    JustWaterWidgetEntry(
        date: .now,
        snapshot: WidgetHydrationSnapshot(
            consumedWater: 1_250,
            dailyGoal: 2_000,
            measurementUnitRawValue: "milliliters",
            date: .now,
            updatedAt: .now
        )
    )
}
