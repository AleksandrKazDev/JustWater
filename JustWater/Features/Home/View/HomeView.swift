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
    
    @State private var isUndoBannerPresented = false
    @State private var isUndoBannerVisible = false
    
    @State private var undoBannerDismissTask: Task<Void, Never>?
    
    private let quickAddAmounts = [100, 200, 300]
    
    private var todayTitle: String {
        Date.now.formatted(
            .dateTime
                .day()
                .month(.wide)
        )
    }
    
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
                                WaterProgressView(
                                    progress: viewModel.hydrationState.progress
                                )
                                
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
            
            if isUndoBannerPresented, let viewModel {
                undoBanner(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $isAddWaterSheetPresented) {
            if let viewModel {
                AddWaterSheet(
                    presets: [100, 200, 300, 500],
                    onAdd: { amount in
                        viewModel.addWater(amount)
                        showUndoBanner()
                    }
                )
            }
        }
        .onAppear {
            if viewModel == nil {
                let storageService = WaterStorageService(
                    context: modelContext
                )
                
                viewModel = HomeViewModel(
                    storageService: storageService
                )
            }
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Today, \(todayTitle)")
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
    
    private func quickAddSection(
        viewModel: HomeViewModel
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(quickAddAmounts, id: \.self) { amount in
                QuickAddButton(amount: amount) {
                    viewModel.addWater(amount)
                    showUndoBanner()
                }
            }
        }
    }
    
    private func undoBanner(
        viewModel: HomeViewModel
    ) -> some View {
        VStack {
            Spacer()
            
            HStack {
                Text("Water added")
                    .font(AppTypography.body)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button("Undo") {
                    undoBannerDismissTask?.cancel()
                    
                    viewModel.undoLastAdd()
                    
                    Task {
                        await hideUndoBanner()
                    }
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
            .opacity(isUndoBannerVisible ? 1 : 0)
            .allowsHitTesting(isUndoBannerVisible)
        }
    }
    
    private func showUndoBanner() {
        undoBannerDismissTask?.cancel()
        
        isUndoBannerPresented = true
        
        withAnimation(.easeInOut(duration: 0.25)) {
            isUndoBannerVisible = true
        }
        
        undoBannerDismissTask = Task {
            try? await Task.sleep(for: .seconds(4))
            
            guard !Task.isCancelled else { return }
            
            await hideUndoBanner()
        }
    }
    
    @MainActor
    private func hideUndoBanner() async {
        withAnimation(.easeInOut(duration: 0.4)) {
            isUndoBannerVisible = false
        }
        
        try? await Task.sleep(for: .milliseconds(400))
        
        if !isUndoBannerVisible {
            isUndoBannerPresented = false
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(PreviewContainer.shared)
}
//import SwiftUI
//import SwiftData
//
//struct HomeView: View {
//    
//    @Environment(\.modelContext) private var modelContext
//    
//    @State private var viewModel: HomeViewModel?
//    @State private var isAddWaterSheetPresented = false
//    @State private var isUndoBannerVisible = false
//    @State private var undoBannerDismissTask: Task<Void, Never>?
//    
//    private let quickAddAmounts = [100, 200, 300]
//    
//    var body: some View {
//        ZStack {
//            AppColors.background
//                .ignoresSafeArea()
//            
//            ScrollView(showsIndicators: false) {
//                if let viewModel {
//                    VStack(spacing: AppSpacing.xl) {
//                        header
//                        
//                        GlassCard {
//                            VStack(spacing: AppSpacing.lg) {
//                                WaterProgressView(progress: viewModel.hydrationState.progress)
//                                
//                                VStack(spacing: AppSpacing.xs) {
//                                    Text("\(viewModel.hydrationState.consumedWater) ml")
//                                        .font(AppTypography.largeTitle)
//                                        .foregroundStyle(AppColors.primaryText)
//                                    
//                                    Text("of \(viewModel.hydrationState.dailyGoal) ml")
//                                        .font(AppTypography.body)
//                                        .foregroundStyle(AppColors.secondaryText)
//                                }
//                            }
//                        }
//                        
//                        PrimaryButton(
//                            title: "Add Water",
//                            systemImage: "plus"
//                        ) {
//                            isAddWaterSheetPresented = true
//                        }
//                        
//                        quickAddSection(viewModel: viewModel)
//                        
//                        RecentActivitySection(
//                            entries: viewModel.hydrationState.entries,
//                            onDelete: viewModel.deleteEntry
//                        )
//                        
//                        Spacer(minLength: AppSpacing.xl)
//                    }
//                    .padding(.horizontal, AppSpacing.lg)
//                    .padding(.top, AppSpacing.xl)
//                }
//            }
//            
//            if isUndoBannerVisible, let viewModel {
//                undoBanner(viewModel: viewModel)
//            }
//        }
//        .sheet(isPresented: $isAddWaterSheetPresented) {
//            if let viewModel {
//                AddWaterSheet(
//                    presets: [100, 200, 300, 500],
//                    onAdd: { amount in
//                        viewModel.addWater(amount)
//                        showUndoBanner()
//                    }
//                )
//            }
//        }
//        .onAppear {
//            if viewModel == nil {
//                let storageService = WaterStorageService(context: modelContext)
//                viewModel = HomeViewModel(storageService: storageService)
//            }
//        }
//    }
//    
//    private var header: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: AppSpacing.xs) {
//                Text("Today")
//                    .font(AppTypography.caption)
//                    .foregroundStyle(AppColors.secondaryText)
//                
//                Text("JustWater")
//                    .font(AppTypography.title)
//                    .foregroundStyle(AppColors.primaryText)
//            }
//            
//            Spacer()
//            
//            Button {
//                print("Settings tapped")
//            } label: {
//                Image(systemName: "gearshape")
//                    .font(.system(size: 20, weight: .semibold))
//                    .foregroundStyle(AppColors.secondaryText)
//                    .frame(width: 44, height: 44)
//                    .background {
//                        Circle()
//                            .fill(AppColors.cardBackground)
//                    }
//            }
//            .buttonStyle(.plain)
//        }
//    }
//    
//    private func quickAddSection(viewModel: HomeViewModel) -> some View {
//        HStack(spacing: AppSpacing.sm) {
//            ForEach(quickAddAmounts, id: \.self) { amount in
//                QuickAddButton(amount: amount) {
//                    viewModel.addWater(amount)
//                    showUndoBanner()
//                }
//            }
//        }
//    }
//    
//    private func undoBanner(viewModel: HomeViewModel) -> some View {
//        VStack {
//            Spacer()
//            
//            HStack {
//                Text("Water added")
//                    .font(AppTypography.body)
//                    .foregroundStyle(.white)
//                
//                Spacer()
//                
//                Button("Undo") {
//                    undoBannerDismissTask?.cancel()
//                    viewModel.undoLastAdd()
//                    
//                    withAnimation(.easeInOut(duration: 0.2)) {
//                        isUndoBannerVisible = false
//                    }
//                }
//                .font(AppTypography.body)
//                .foregroundStyle(AppColors.lightBlue)
//            }
//            .padding(AppSpacing.md)
//            .background {
//                Capsule()
//                    .fill(.black.opacity(0.82))
//            }
//            .padding(.horizontal, AppSpacing.lg)
//            .padding(.bottom, AppSpacing.lg)
//            .transition(.move(edge: .bottom).combined(with: .opacity))
//        }
//    }
//    
//    private func showUndoBanner() {
//        undoBannerDismissTask?.cancel()
//        
//        withAnimation(.easeOut(duration: 0.25)) {
//            isUndoBannerVisible = true
//        }
//        
//        undoBannerDismissTask = Task {
//            try? await Task.sleep(for: .seconds(5))
//            
//            guard !Task.isCancelled else { return }
//            
//            await MainActor.run {
//                withAnimation(.easeInOut(duration: 0.25)) {
//                    isUndoBannerVisible = false
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    HomeView()
//        .modelContainer(PreviewContainer.shared)
//}
