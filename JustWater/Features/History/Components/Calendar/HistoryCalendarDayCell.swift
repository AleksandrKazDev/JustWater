//
//  HistoryCalendarDayCell.swift
//  JustWater
//
//  Created by сонный on 02.06.2026.
//

import SwiftUI

struct HistoryCalendarDayCell: View {
    
    // MARK: - Properties
    
    let date: Date
    let state: HistoryCalendarDayState?
    let isSelected: Bool
    let isToday: Bool
    let cellSize: CGFloat
    let onSelect: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button {
            HapticService.selection()
            onSelect()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        isSelected
                        ? AppColors.primaryBlue
                        : Color.clear
                    )
                    .frame(
                        width: cellSize,
                        height: cellSize
                    )
                
                if let state,
                   state.hasEntries,
                   !isSelected {
                    HistoryCalendarProgressRing(
                        progress: state.progress,
                        isGoalReached: state.isGoalReached,
                        cellSize: cellSize
                    )
                }
                
                if isToday && !isSelected && state == nil {
                    Circle()
                        .stroke(
                            AppColors.primaryText.opacity(0.18),
                            lineWidth: 1
                        )
                        .frame(
                            width: cellSize,
                            height: cellSize
                        )
                }
                
                Text(dayNumber)
                    .font(AppTypography.body)
                    .foregroundStyle(
                        isSelected ? .white : AppColors.primaryText
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(
                width: cellSize,
                height: cellSize
            )
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Computed Properties
    
    private var dayNumber: String {
        String(
            Calendar.current.component(
                .day,
                from: date
            )
        )
    }
}

// MARK: - HistoryCalendarProgressRing

private struct HistoryCalendarProgressRing: View {
    
    // MARK: - Properties
    
    let progress: Double
    let isGoalReached: Bool
    let cellSize: CGFloat
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    AppColors.primaryBlue.opacity(0.12),
                    lineWidth: 2
                )
                .frame(
                    width: cellSize,
                    height: cellSize
                )
            
            Circle()
                .trim(
                    from: 0,
                    to: progress
                )
                .stroke(
                    AppColors.primaryBlue.opacity(
                        isGoalReached ? 0.85 : 0.58
                    ),
                    style: StrokeStyle(
                        lineWidth: 2,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .frame(
                    width: cellSize,
                    height: cellSize
                )
        }
    }
}
