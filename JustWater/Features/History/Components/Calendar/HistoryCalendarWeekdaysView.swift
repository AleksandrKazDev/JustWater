//
//  HistoryCalendarWeekdaysView.swift
//  JustWater
//
//  Created by сонный on 02.06.2026.
//

import SwiftUI

struct HistoryCalendarWeekdaysView: View {
    
    // MARK: - Properties
    
    let weekdaySymbols: [String]
    let columns: [GridItem]
    let height: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        LazyVGrid(
            columns: columns,
            spacing: 0
        ) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText.opacity(0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(height: height)
            }
        }
    }
}
