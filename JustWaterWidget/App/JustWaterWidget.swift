//
//  JustWaterWidget.swift
//  JustWaterWidget
//
//  Created by сонный on 09.06.2026.
//

import WidgetKit
import SwiftUI

struct JustWaterWidget: Widget {
    
    // MARK: - Properties
    
    let kind = WidgetConstants.kind
    
    // MARK: - Body
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: JustWaterWidgetProvider()
        ) { entry in
            JustWaterWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("JustWater")
        .description(String(localized: "widget.description"))
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}
