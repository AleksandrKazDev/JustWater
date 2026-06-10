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
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    // MARK: - Body
    
    var body: some View {
        content
            .widgetURL(URL(string: "justwater://home"))
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private var content: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
            
        case .systemMedium:
            MediumWidgetView(entry: entry)
            
        default:
            SmallWidgetView(entry: entry)
        }
    }
}
