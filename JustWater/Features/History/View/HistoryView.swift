//
//  HistoryView.swift
//  JustWater
//
//  Created by сонный on 15.05.2026.
//

import SwiftUI
import SwiftData

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
                            statisticsSection(analytics.statistics)
                            
                            chartPlaceholder(analytics)
                            
                            entriesSection(analytics.entries)
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
    
    private func chartPlaceholder(
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
                        .frame(maxWidth: .infinity, minHeight: 120)
                } else {
                    VStack(spacing: AppSpacing.sm) {
                        ForEach(analytics.chartPoints.prefix(8)) { point in
                            HStack {
                                Text(point.label)
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .frame(width: 56, alignment: .leading)
                                
                                GeometryReader { proxy in
                                    Capsule()
                                        .fill(AppColors.primaryBlue.opacity(0.35))
                                        .frame(
                                            width: barWidth(
                                                amount: point.amount,
                                                maxAmount: analytics.chartPoints.map(\.amount).max() ?? 1,
                                                containerWidth: proxy.size.width
                                            )
                                        )
                                }
                                .frame(height: 10)
                                
                                Text("\(point.amount)")
                                    .font(AppTypography.caption)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .frame(width: 48, alignment: .trailing)
                            }
                        }
                    }
                    .frame(minHeight: 120)
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
    
    // MARK: - Helpers
    
    private func barWidth(
        amount: Int,
        maxAmount: Int,
        containerWidth: CGFloat
    ) -> CGFloat {
        guard maxAmount > 0 else { return 0 }
        
        let ratio = Double(amount) / Double(maxAmount)
        return max(containerWidth * ratio, 8)
    }
    
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
