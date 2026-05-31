//
//  HistoryDatePickerSheet.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HistoryDatePickerSheet: View {
    
    // MARK: - Properties
    
    let selectedDate: Date
    let dayStatesProvider: (Date) -> [Date: HistoryCalendarDayState]
    let onSelectDate: (Date) -> Void
    
    // MARK: - State
    
    @State private var internalSelectedDate: Date
    @State private var visibleMonth: Date
    @State private var dayStates: [Date: HistoryCalendarDayState]
    @State private var isMonthYearPickerPresented = false
    
    // MARK: - Private Properties
    
    private let calendar = Calendar.current
    
    // MARK: - Initializer
    
    init(
        selectedDate: Date,
        dayStatesProvider: @escaping (Date) -> [Date: HistoryCalendarDayState],
        onSelectDate: @escaping (Date) -> Void
    ) {
        self.selectedDate = selectedDate
        self.dayStatesProvider = dayStatesProvider
        self.onSelectDate = onSelectDate
        
        let month = Calendar.current.dateInterval(
            of: .month,
            for: selectedDate
        )?.start ?? selectedDate
        
        self._internalSelectedDate = State(
            initialValue: selectedDate
        )
        
        self._visibleMonth = State(
            initialValue: month
        )
        
        self._dayStates = State(
            initialValue: dayStatesProvider(month)
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            titleView
            
            GeometryReader { proxy in
                let metrics = calendarMetrics(
                    availableWidth: proxy.size.width
                )
                
                VStack(spacing: AppSpacing.sm) {
                    headerView
                    
                    if isMonthYearPickerPresented {
                        monthYearPicker
                            .transition(.opacity)
                    } else {
                        weekdaysView
                        
                        calendarGrid(
                            cellSize: metrics.cellSize,
                            gridSpacing: metrics.gridSpacing
                        )
                        .transition(.opacity)
                    }
                }
            }
            .frame(height: contentHeight)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.md)
        .background {
            AppColors.background
                .ignoresSafeArea()
        }
        .presentationDetents([.fraction(sheetFraction)])
        .presentationDragIndicator(.visible)
        .presentationBackground(AppColors.background)
        .onChange(of: visibleMonth) { _, newValue in
            dayStates = dayStatesProvider(newValue)
        }
        .onChange(of: selectedDate) { _, newValue in
            syncWithSelectedDate(newValue)
        }
    }
    
    // MARK: - Title
    
    private var titleView: some View {
        Text(String(localized: "Select Date"))
            .font(AppTypography.title2)
            .foregroundStyle(AppColors.primaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.top, AppSpacing.lg)
            .frame(maxWidth: .infinity)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                HapticService.selection()
                
                withAnimation(.snappy(duration: 0.22)) {
                    isMonthYearPickerPresented.toggle()
                }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Text(monthTitle)
                        .font(AppTypography.title2)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    Image(
                        systemName: isMonthYearPickerPresented
                        ? "chevron.down"
                        : "chevron.right"
                    )
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.primaryBlue)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Spacer(minLength: AppSpacing.md)
            
            HStack(spacing: AppSpacing.sm) {
                Button {
                    HapticService.selection()
                    shiftVisibleMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(AppColors.primaryBlue)
                        .frame(width: 40, height: 40)
                }
                
                Button {
                    HapticService.selection()
                    shiftVisibleMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(AppColors.primaryBlue)
                        .frame(width: 40, height: 40)
                }
            }
        }
        .frame(height: headerHeight)
    }
    
    // MARK: - Month / Year Picker
    
    private var monthYearPicker: some View {
        HStack(spacing: AppSpacing.md) {
            Picker(
                String(localized: "Month"),
                selection: Binding(
                    get: {
                        calendar.component(
                            .month,
                            from: internalSelectedDate
                        )
                    },
                    set: { newMonth in
                        HapticService.selection()
                        updateSelectedDate(month: newMonth)
                    }
                )
            ) {
                ForEach(1...12, id: \.self) { month in
                    Text(monthName(for: month))
                        .tag(month)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
            
            Picker(
                String(localized: "Year"),
                selection: Binding(
                    get: {
                        calendar.component(
                            .year,
                            from: internalSelectedDate
                        )
                    },
                    set: { newYear in
                        HapticService.selection()
                        updateSelectedDate(year: newYear)
                    }
                )
            ) {
                ForEach(yearRange, id: \.self) { year in
                    Text(String(year))
                        .tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .frame(height: pickerHeight)
    }
    
    // MARK: - Weekdays
    
    private var weekdaysView: some View {
        LazyVGrid(
            columns: gridColumns,
            spacing: 0
        ) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol.uppercased())
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText.opacity(0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .frame(height: weekdayHeight)
            }
        }
    }
    
    // MARK: - Grid
    
    private func calendarGrid(
        cellSize: CGFloat,
        gridSpacing: CGFloat
    ) -> some View {
        LazyVGrid(
            columns: gridColumns,
            spacing: gridSpacing
        ) {
            ForEach(calendarDays) { item in
                if let date = item.date {
                    dayCell(
                        for: date,
                        cellSize: cellSize
                    )
                } else {
                    Color.clear
                        .frame(
                            width: cellSize,
                            height: cellSize
                        )
                }
            }
        }
    }
    
    private func dayCell(
        for date: Date,
        cellSize: CGFloat
    ) -> some View {
        let isSelected = calendar.isDate(
            date,
            inSameDayAs: internalSelectedDate
        )
        
        let isToday = calendar.isDateInToday(
            date
        )
        
        let normalizedDate = calendar.startOfDay(
            for: date
        )
        
        let state = dayStates[normalizedDate] ?? .empty
        
        return Button {
            HapticService.selection()
            selectDate(date)
        } label: {
            ZStack {
                Circle()
                    .fill(
                        backgroundColor(
                            state: state,
                            isSelected: isSelected
                        )
                    )
                    .frame(
                        width: cellSize,
                        height: cellSize
                    )
                
                if isToday && !isSelected {
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
                
                if state == .goalReached && !isSelected {
                    Circle()
                        .stroke(
                            AppColors.primaryBlue.opacity(0.45),
                            lineWidth: 1.5
                        )
                        .frame(
                            width: cellSize,
                            height: cellSize
                        )
                }
                
                Text(dayNumber(for: date))
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
    
    // MARK: - Layout Constants
    
    private var headerHeight: CGFloat {
        48
    }
    
    private var weekdayHeight: CGFloat {
        30
    }
    
    private var pickerHeight: CGFloat {
        220
    }
    
    private var calendarRowCount: Int {
        6
    }
    
    private var contentHeight: CGFloat {
        if isMonthYearPickerPresented {
            return headerHeight
            + AppSpacing.sm
            + pickerHeight
        }
        
        let estimatedCellSize: CGFloat = 42
        let estimatedGridSpacing: CGFloat = AppSpacing.md
        
        let gridHeight = CGFloat(calendarRowCount) * estimatedCellSize
        + CGFloat(max(calendarRowCount - 1, 0)) * estimatedGridSpacing
        
        return headerHeight
        + AppSpacing.sm
        + weekdayHeight
        + AppSpacing.sm
        + gridHeight
    }
    
    private var sheetFraction: CGFloat {
        isMonthYearPickerPresented ? 0.52 : 0.62
    }
    
    // MARK: - Computed Properties
    
    private var gridColumns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 0),
            count: 7
        )
    }
    
    private var monthTitle: String {
        visibleMonth.formatted(
            .dateTime
                .month(.wide)
                .year()
        )
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        
        return Array(symbols[firstWeekdayIndex...])
        + Array(symbols[..<firstWeekdayIndex])
    }
    
    private var yearRange: ClosedRange<Int> {
        let currentYear = calendar.component(
            .year,
            from: Date()
        )
        
        return (currentYear - 20)...(currentYear + 20)
    }
    
    private var calendarDays: [CalendarDayItem] {
        guard let monthInterval = calendar.dateInterval(
            of: .month,
            for: visibleMonth
        ),
              let daysRange = calendar.range(
                of: .day,
                in: .month,
                for: visibleMonth
              ) else {
            return []
        }
        
        let firstDay = monthInterval.start
        
        let leadingItems = (0..<leadingEmptyDaysCount(for: firstDay)).map { index in
            CalendarDayItem(
                id: "leading-\(index)",
                date: nil
            )
        }
        
        let dateItems: [CalendarDayItem] = daysRange.compactMap { day in
            guard let date = calendar.date(
                byAdding: .day,
                value: day - 1,
                to: firstDay
            ) else {
                return nil
            }
            
            return CalendarDayItem(
                id: "day-\(calendar.startOfDay(for: date).timeIntervalSince1970)",
                date: date
            )
        }
        
        let totalItems = leadingItems + dateItems
        
        let trailingCount = max(
            0,
            42 - totalItems.count
        )
        
        let trailingItems = (0..<trailingCount).map { index in
            CalendarDayItem(
                id: "trailing-\(index)",
                date: nil
            )
        }
        
        return totalItems + trailingItems
    }
    
    // MARK: - Private Methods
    
    private func selectDate(
        _ date: Date
    ) {
        internalSelectedDate = date
        visibleMonth = monthStart(for: date)
        onSelectDate(date)
    }
    
    private func syncWithSelectedDate(
        _ date: Date
    ) {
        internalSelectedDate = date
        visibleMonth = monthStart(for: date)
    }
    
    private func shiftVisibleMonth(
        by value: Int
    ) {
        guard let newVisibleMonth = calendar.date(
            byAdding: .month,
            value: value,
            to: visibleMonth
        ) else {
            return
        }
        
        let newDate = dateByKeepingSelectedDay(
            in: newVisibleMonth
        )
        
        selectDate(newDate)
    }
    
    private func updateSelectedDate(
        month: Int
    ) {
        let currentYear = calendar.component(
            .year,
            from: internalSelectedDate
        )
        
        updateSelectedDate(
            year: currentYear,
            month: month
        )
    }
    
    private func updateSelectedDate(
        year: Int
    ) {
        let currentMonth = calendar.component(
            .month,
            from: internalSelectedDate
        )
        
        updateSelectedDate(
            year: year,
            month: currentMonth
        )
    }
    
    private func updateSelectedDate(
        year: Int,
        month: Int
    ) {
        let selectedDay = calendar.component(
            .day,
            from: internalSelectedDate
        )
        
        var components = DateComponents()
        components.calendar = calendar
        components.year = year
        components.month = month
        components.day = 1
        
        guard let monthStart = calendar.date(
            from: components
        ) else {
            return
        }
        
        let validDay = min(
            selectedDay,
            numberOfDays(in: monthStart)
        )
        
        components.day = validDay
        
        guard let newDate = calendar.date(
            from: components
        ) else {
            return
        }
        
        selectDate(newDate)
    }
    
    private func dateByKeepingSelectedDay(
        in monthDate: Date
    ) -> Date {
        let selectedDay = calendar.component(
            .day,
            from: internalSelectedDate
        )
        
        let validDay = min(
            selectedDay,
            numberOfDays(in: monthDate)
        )
        
        var components = calendar.dateComponents(
            [.year, .month],
            from: monthDate
        )
        
        components.day = validDay
        
        return calendar.date(
            from: components
        ) ?? monthDate
    }
    
    private func monthStart(
        for date: Date
    ) -> Date {
        calendar.dateInterval(
            of: .month,
            for: date
        )?.start ?? date
    }
    
    private func numberOfDays(
        in monthDate: Date
    ) -> Int {
        calendar.range(
            of: .day,
            in: .month,
            for: monthDate
        )?.count ?? 31
    }
    
    private func leadingEmptyDaysCount(
        for firstDay: Date
    ) -> Int {
        let weekday = calendar.component(
            .weekday,
            from: firstDay
        )
        
        return (
            weekday - calendar.firstWeekday + 7
        ) % 7
    }
    
    private func monthName(
        for month: Int
    ) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        
        return formatter.monthSymbols[month - 1]
    }
    
    private func dayNumber(
        for date: Date
    ) -> String {
        "\(calendar.component(.day, from: date))"
    }
    
    private func backgroundColor(
        state: HistoryCalendarDayState,
        isSelected: Bool
    ) -> Color {
        if isSelected {
            return AppColors.primaryBlue
        }
        
        switch state {
        case .empty:
            return .clear
            
        case .hasEntries:
            return AppColors.primaryBlue.opacity(0.10)
            
        case .goalReached:
            return AppColors.primaryBlue.opacity(0.14)
        }
    }
    
    private func calendarMetrics(
        availableWidth: CGFloat
    ) -> CalendarMetrics {
        let availableCellWidth = availableWidth / 7
        
        let cellSize = min(
            max(availableCellWidth * 0.72, 36),
            46
        )
        
        let gridSpacing = max(
            AppSpacing.sm,
            min(AppSpacing.md, cellSize * 0.24)
        )
        
        return CalendarMetrics(
            cellSize: cellSize,
            gridSpacing: gridSpacing
        )
    }
}

// MARK: - CalendarDayItem

private struct CalendarDayItem: Identifiable {
    let id: String
    let date: Date?
}

// MARK: - CalendarMetrics

private struct CalendarMetrics {
    let cellSize: CGFloat
    let gridSpacing: CGFloat
}
