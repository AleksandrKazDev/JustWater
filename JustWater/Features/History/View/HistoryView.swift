//
//  HistoryView.swift
//  JustWater
//
//  Created by сонный on 15.05.2026.
//

import SwiftUI
import SwiftData
import Charts

struct HistoryView: View {
    
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    
    @State private var viewModel: HistoryViewModel?
    @State private var isDatePickerPresented = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                if let viewModel {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        periodPicker(viewModel: viewModel)
                        
                        periodNavigation(viewModel: viewModel)
                        
                        if let analytics = viewModel.analytics {
                            historyContent(
                                analytics,
                                viewModel: viewModel
                            )
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
        }
        .onAppear {
            setupViewModelIfNeeded()
            viewModel?.loadAnalytics()
        }
        .sheet(isPresented: $isDatePickerPresented) {
            if let viewModel {
                datePickerSheet(viewModel: viewModel)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    private func periodPicker(
        viewModel: HistoryViewModel
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(HistoryPeriod.allCases) { period in
                Button {
                    viewModel.selectPeriod(period)
                } label: {
                    Text(period.title)
                        .font(AppTypography.caption)
                        .foregroundStyle(
                            viewModel.selectedPeriod == period
                            ? .white
                            : AppColors.primaryText
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background {
                            Capsule()
                                .fill(
                                    viewModel.selectedPeriod == period
                                    ? AppColors.primaryBlue
                                    : AppColors.cardBackground
                                )
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func periodNavigation(
        viewModel: HistoryViewModel
    ) -> some View {
        HStack {
            Button {
                viewModel.showPreviousPeriod()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: 40, height: 40)
                    .background {
                        Circle()
                            .fill(AppColors.cardBackground)
                    }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button {
                isDatePickerPresented = true
            } label: {
                Text(viewModel.periodTitle)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button {
                viewModel.showNextPeriod()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)
                    .frame(width: 40, height: 40)
                    .background {
                        Circle()
                            .fill(AppColors.cardBackground)
                    }
            }
            .buttonStyle(.plain)
        }
    }
    
    private func historyContent(
        _ analytics: HistoryAnalytics,
        viewModel: HistoryViewModel
    ) -> some View {
        VStack(spacing: AppSpacing.lg) {
            switch analytics.period {
            case .day:
                statisticsSection(analytics.statistics)
                chartSection(analytics)
                entriesSection(
                    analytics.entries,
                    onDelete: viewModel.deleteEntry
                )
                
            case .week:
                periodStatisticsSection(
                    analytics.statistics,
                    averageTitle: "Daily Avg",
                    bestTitle: "Best Day"
                )
                chartSection(analytics)
                periodSummarySection(
                    title: "Daily Summary",
                    points: analytics.chartPoints,
                    labelProvider: weekSummaryLabel
                )
                
            case .month:
                periodStatisticsSection(
                    analytics.statistics,
                    averageTitle: "Daily Avg",
                    bestTitle: "Best Day"
                )
                chartSection(analytics)
                
            case .year:
                periodStatisticsSection(
                    analytics.statistics,
                    averageTitle: "Monthly Avg",
                    bestTitle: "Best Month"
                )
                chartSection(analytics)
                periodSummarySection(
                    title: "Monthly Summary",
                    points: analytics.chartPoints,
                    labelProvider: { $0.label }
                )
            }
        }
    }
    
    private func statisticsSection(
        _ statistics: HistoryStatistics
    ) -> some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                statisticCard(
                    title: "Total",
                    value: "\(statistics.totalAmount) ml"
                )
                
                statisticCard(
                    title: "Average",
                    value: "\(statistics.averageAmount) ml"
                )
            }
            
            HStack(spacing: AppSpacing.md) {
                statisticCard(
                    title: "Entries",
                    value: "\(statistics.entriesCount)"
                )
                
                statisticCard(
                    title: "Goal",
                    value: "\(Int(statistics.completionRate * 100))%"
                )
            }
        }
    }
    
    private func periodStatisticsSection(
        _ statistics: HistoryStatistics,
        averageTitle: String,
        bestTitle: String
    ) -> some View {
        VStack(spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                statisticCard(
                    title: "Total",
                    value: "\(statistics.totalAmount) ml"
                )
                
                statisticCard(
                    title: averageTitle,
                    value: "\(statistics.averageAmount) ml"
                )
            }
            
            HStack(spacing: AppSpacing.md) {
                statisticCard(
                    title: "Goal Days",
                    value: "\(statistics.goalReachedCount)"
                )
                
                statisticCard(
                    title: bestTitle,
                    value: statistics.bestAmount > 0
                    ? "\(statistics.bestAmount) ml"
                    : "—"
                )
            }
        }
    }
    
    private func statisticCard(
        title: String,
        value: String
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                
                Text(value)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func chartSection(
        _ analytics: HistoryAnalytics
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(chartTitle(for: analytics.period))
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                if analytics.period != .day {
                    HStack(spacing: AppSpacing.xs) {
                        Capsule()
                            .fill(AppColors.primaryBlue.opacity(0.35))
                            .frame(width: 22, height: 2)
                        
                        Text("Daily goal")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
                
                if analytics.chartPoints.isEmpty {
                    Text("No data for selected period")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: 160)
                } else {
                    Chart {
                        ForEach(analytics.chartPoints) { point in
                            switch analytics.period {
                            case .day, .year:
                                BarMark(
                                    x: .value("Period", point.label),
                                    y: .value("Water", point.amount)
                                )
                                .foregroundStyle(AppColors.primaryBlue.gradient)
                                .cornerRadius(6)
                                
                            case .week, .month:
                                LineMark(
                                    x: .value("Period", point.label),
                                    y: .value("Water", point.amount)
                                )
                                .foregroundStyle(AppColors.primaryBlue)
                                .lineStyle(
                                    StrokeStyle(
                                        lineWidth: 3,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                                
                                AreaMark(
                                    x: .value("Period", point.label),
                                    y: .value("Water", point.amount)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            AppColors.primaryBlue.opacity(0.22),
                                            AppColors.primaryBlue.opacity(0.02)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                        }
                        
                        if analytics.period != .day {
                            RuleMark(
                                y: .value(
                                    "Goal",
                                    AppSettingsStorage.dailyGoal
                                )
                            )
                            .foregroundStyle(AppColors.primaryBlue.opacity(0.35))
                            .lineStyle(
                                StrokeStyle(
                                    lineWidth: 1.5,
                                    dash: [6]
                                )
                            )
                        }
                    }
                    .frame(height: 180)
                    .chartYScale(domain: chartYDomain(for: analytics))
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartXAxis {
                        chartXAxis(for: analytics)
                    }
                }
            }
        }
    }
    
    private func entriesSection(
        _ entries: [WaterEntry],
        onDelete: @escaping (WaterEntry) -> Void
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Entries")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                if entries.isEmpty {
                    Text("No entries yet")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                } else {
                    VStack(spacing: AppSpacing.md) {
                        ForEach(entries) { entry in
                            HStack {
                                Text("\(entry.amount) ml")
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.primaryText)
                                
                                Spacer()
                                
                                Text(entry.date, style: .time)
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.secondaryText)
                                
                                Button {
                                    withAnimation(
                                        .spring(
                                            response: 0.45,
                                            dampingFraction: 0.9
                                        )
                                    ) {
                                        onDelete(entry)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(AppColors.secondaryText)
                                        .frame(width: 32, height: 32)
                                }
                                .buttonStyle(.plain)
                            }
                            .transition(
                                .asymmetric(
                                    insertion: .opacity,
                                    removal: .opacity.combined(
                                        with: .scale(scale: 0.96)
                                    )
                                )
                            )
                        }
                    }
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.9),
                        value: entries.map(\.id)
                    )
                }
            }
        }
    }
    
    private func periodSummarySection(
        title: String,
        points: [HistoryChartPoint],
        labelProvider: @escaping (HistoryChartPoint) -> String
    ) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                if points.isEmpty {
                    Text("No data for selected period")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                } else {
                    VStack(spacing: AppSpacing.md) {
                        ForEach(points) { point in
                            HStack {
                                Text(labelProvider(point))
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.primaryText)
                                
                                Spacer()
                                
                                Text("\(point.amount) ml")
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.secondaryText)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func datePickerSheet(
        viewModel: HistoryViewModel
    ) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text("Select Date")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            DatePicker(
                "Date",
                selection: Binding(
                    get: {
                        viewModel.referenceDate
                    },
                    set: { newDate in
                        viewModel.selectReferenceDate(newDate)
                    }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
        }
        .padding(AppSpacing.lg)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Helpers
    
    private func chartTitle(
        for period: HistoryPeriod
    ) -> String {
        switch period {
        case .day:
            return "Intake by Time"
            
        case .week, .month, .year:
            return "Consumption"
        }
    }
    
    @AxisContentBuilder
    private func chartXAxis(
        for analytics: HistoryAnalytics
    ) -> some AxisContent {
        switch analytics.period {
        case .month:
            AxisMarks(
                values: monthAxisLabels(from: analytics.chartPoints)
            ) { _ in
                AxisValueLabel()
                    .foregroundStyle(AppColors.secondaryText)
            }
            
        default:
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }
    
    private func monthAxisLabels(
        from points: [HistoryChartPoint]
    ) -> [String] {
        points
            .map(\.label)
            .filter { label in
                guard let day = Int(label) else {
                    return false
                }
                
                return day == 1 ||
                day == 5 ||
                day == 10 ||
                day == 15 ||
                day == 20 ||
                day == 25 ||
                day == 30
            }
    }
    
    private func weekSummaryLabel(
        for point: HistoryChartPoint
    ) -> String {
        let weekday = point.date.formatted(
            .dateTime.weekday(.abbreviated)
        )
        
        let day = point.date.formatted(
            .dateTime.day()
        )
        
        return "\(weekday) \(day)"
    }
    
    private func chartYDomain(
        for analytics: HistoryAnalytics
    ) -> ClosedRange<Int> {
        let maxAmount = analytics.chartPoints.map(\.amount).max() ?? 0
        
        switch analytics.period {
        case .day:
            let upperBound = max(
                500,
                roundedChartUpperBound(maxAmount)
            )
            
            return 0...upperBound
            
        case .week, .month, .year:
            let upperBound = max(
                AppSettingsStorage.dailyGoal,
                roundedChartUpperBound(maxAmount)
            )
            
            return 0...upperBound
        }
    }
    
    private func roundedChartUpperBound(
        _ value: Int
    ) -> Int {
        guard value > 0 else { return 500 }
        
        let step = 500
        return ((value + step - 1) / step) * step
    }
    
    // MARK: - Setup
    
    private func setupViewModelIfNeeded() {
        guard viewModel == nil else { return }
        
        let storageService = WaterStorageService(context: modelContext)
        viewModel = HistoryViewModel(storageService: storageService)
    }
}

// MARK: - Preview

//#Preview {
//    HistoryView()
//        .modelContainer(PreviewContainer.shared)
//}
