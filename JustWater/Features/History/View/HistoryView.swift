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
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                if let viewModel {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        periodPicker(viewModel: viewModel)
                        
                        if let analytics = viewModel.analytics {
                            historyContent(analytics)
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
                Text("Consumption")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                if analytics.chartPoints.isEmpty {
                    Text("No data for selected period")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: 160)
                } else {
                    Chart(analytics.chartPoints) { point in
                        BarMark(
                            x: .value("Period", point.label),
                            y: .value("Water", point.amount)
                        )
                        .foregroundStyle(AppColors.primaryBlue.gradient)
                        .cornerRadius(6)
                    }
                    .frame(height: 180)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisValueLabel()
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                }
            }
        }
    }
    
    private func entriesSection(
        _ entries: [WaterEntry]
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Entries")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            if entries.isEmpty {
                emptyState
            } else {
                GlassCard {
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
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        Text("No entries yet")
            .font(AppTypography.body)
            .foregroundStyle(AppColors.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.lg)
    }
    
    
    private func historyContent(
        _ analytics: HistoryAnalytics
    ) -> some View {
        VStack(spacing: AppSpacing.lg) {
            switch analytics.period {
            case .day:
                statisticsSection(analytics.statistics)
                chartSection(analytics)
                entriesSection(analytics.entries)
                
            case .week:
                periodStatisticsSection(
                    analytics.statistics,
                    averageTitle: "Daily Avg",
                    bestTitle: "Best Day"
                )
                chartSection(analytics)
                periodSummarySection(
                    title: "Daily Summary",
                    points: analytics.chartPoints
                )
                
            case .month:
                periodStatisticsSection(
                    analytics.statistics,
                    averageTitle: "Daily Avg",
                    bestTitle: "Best Day"
                )
                chartSection(analytics)
                periodSummarySection(
                    title: "Month Summary",
                    points: analytics.chartPoints
                )
                
            case .year:
                periodStatisticsSection(
                    analytics.statistics,
                    averageTitle: "Monthly Avg",
                    bestTitle: "Best Month"
                )
                chartSection(analytics)
                periodSummarySection(
                    title: "Monthly Summary",
                    points: analytics.chartPoints
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

    private func periodSummarySection(
        title: String,
        points: [HistoryChartPoint]
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            if points.isEmpty {
                emptyState
            } else {
                GlassCard {
                    VStack(spacing: AppSpacing.md) {
                        ForEach(points) { point in
                            HStack {
                                Text(point.label)
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
    // MARK: - Helpers
    
    
    // MARK: - Setup
    
    private func setupViewModelIfNeeded() {
        guard viewModel == nil else { return }
        
        let storageService = WaterStorageService(context: modelContext)
        viewModel = HistoryViewModel(storageService: storageService)
    }
}

// MARK: - Preview
//
//#Preview {
//    HistoryView()
//        .modelContainer(PreviewContainer.shared)
//}
