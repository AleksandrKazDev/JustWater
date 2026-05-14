//
//  ContentView.swift
//  JustWater
//
//  Created by сонный on 10.05.2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel: HomeViewModel?
    @State private var isAddWaterSheetPresented = false
    @State private var isUndoBannerVisible = false
    
    private let quickAddAmounts = [100, 200, 300]
    
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                if let viewModel {
                    VStack(spacing: AppSpacing.xl) {
                        header
                        
                        GlassCard {
                            VStack(spacing: AppSpacing.lg) {
                                WaterProgressView(progress: viewModel.hydrationState.progress)
                                
                                VStack(spacing: AppSpacing.xs) {
                                    Text("\(viewModel.hydrationState.consumedWater) ml")
                                        .font(AppTypography.largeTitle)
                                        .foregroundStyle(AppColors.primaryText)
                                    
                                    Text("of \(viewModel.hydrationState.dailyGoal) ml")
                                        .font(AppTypography.body)
                                        .foregroundStyle(AppColors.secondaryText)
                                }
                            }
                        }
                        
                        PrimaryButton(
                            title: "Add Water",
                            systemImage: "plus"
                        ) {
                            isAddWaterSheetPresented = true
                        }
                        
                        quickAddSection(viewModel: viewModel)
                        
                        RecentActivitySection(
                            entries: viewModel.hydrationState.entries,
                            onDelete: viewModel.deleteEntry
                        )
                        
                        Spacer(minLength: AppSpacing.xl)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.xl)
                }
            }
            
            if isUndoBannerVisible, let viewModel {
                undoBanner(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $isAddWaterSheetPresented) {
            if let viewModel {
                AddWaterSheet(
                    presets: [100, 200, 300, 500],
                    onAdd: { amount in
                        viewModel.addWater(amount)
                        isUndoBannerVisible = true
                    }
                )
            }
        }
        .onAppear {
            if viewModel == nil {
                let storageService = WaterStorageService(context: modelContext)
                viewModel = HomeViewModel(storageService: storageService)
            }
        }
        .animation(
            .spring(response: 0.35, dampingFraction: 0.9),
            value: isUndoBannerVisible
        )
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Today")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.secondaryText)
                
                Text("JustWater")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.primaryText)
            }
            
            Spacer()
            
            Button {
                print("Settings tapped")
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.secondaryText)
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(AppColors.cardBackground)
                    }
            }
            .buttonStyle(.plain)
        }
    }
    
    private func quickAddSection(viewModel: HomeViewModel) -> some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(quickAddAmounts, id: \.self) { amount in
                QuickAddButton(amount: amount) {
                    viewModel.addWater(amount)
                    isUndoBannerVisible = true
                }
            }
        }
    }
    
    private func undoBanner(viewModel: HomeViewModel) -> some View {
        VStack {
            Spacer()
            
            HStack {
                Text("Water added")
                    .font(AppTypography.body)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button("Undo") {
                    viewModel.undoLastAdd()
                    isUndoBannerVisible = false
                }
                .font(AppTypography.body)
                .foregroundStyle(AppColors.lightBlue)
            }
            .padding(AppSpacing.md)
            .background {
                Capsule()
                    .fill(.black.opacity(0.82))
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.bottom, AppSpacing.lg)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(PreviewContainer.shared)
}
