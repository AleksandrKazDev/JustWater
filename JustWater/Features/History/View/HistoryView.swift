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
                        header
                        
                        if viewModel.summaries.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.summaries) { summary in
                                Text("\(summary.totalAmount) ml")
                                    .font(AppTypography.headline)
                                    .foregroundStyle(AppColors.primaryText)
                            }
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
        }
        .onAppear {
            setupViewModelIfNeeded()
        }
    }
    
    // MARK: - Components
    
    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("History")
                .font(AppTypography.title)
                .foregroundStyle(AppColors.primaryText)
            
            Text("Your hydration by day")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
        }
    }
    
    private var emptyState: some View {
        GlassCard {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "calendar")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppColors.primaryBlue)
                
                Text("No history yet")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("Your daily hydration history will appear here.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Setup
    
    private func setupViewModelIfNeeded() {
        guard viewModel == nil else { return }
        
        let storageService = WaterStorageService(context: modelContext)
        viewModel = HistoryViewModel(storageService: storageService)
    }
}

// MARK: - Preview

#Preview {
    HistoryView()
        .modelContainer(PreviewContainer.shared)
}
