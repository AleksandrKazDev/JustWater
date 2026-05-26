//
//  ContentView.swift
//  JustWater
//
//  Created by сонный on 10.05.2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppCoordinator.self) private var coordinator
    
    // MARK: - State
    
    @State private var viewModel: HomeViewModel?
    @State private var isAddWaterSheetPresented = false
    @State private var isUndoBannerPresented = false
    @State private var isUndoBannerVisible = false
    @State private var isHistoryPresented = false
    @State private var undoBannerMessage = " "
    @State private var undoBannerDismissTask: Task<Void, Never>?
    
    // MARK: - Constants
    
    private let quickAddAmounts = [100, 200, 300]
    private let addWaterPresetAmounts = [100, 200, 300, 500]
    
    // MARK: - Computed Properties
    
    private var todayTitle: String {
        Date.now.formatted(
            .dateTime
                .day()
                .month(.wide)
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                if let viewModel {
                    VStack(spacing: AppSpacing.xl) {
                        HomeHeader(
                            todayTitle: todayTitle,
                            onResetOnboarding: coordinator.resetOnboarding,
                            onGoalUpdated: {
                                viewModel.loadEntries()
                            }
                        )
                        
                        HomeProgressCard(
                            hydrationState: viewModel.hydrationState
                        )
                        
                        PrimaryButton(
                            title: "Add Water",
                            systemImage: "plus"
                        ) {
                            isAddWaterSheetPresented = true
                        }
                        
                        QuickAddSection(
                            amounts: quickAddAmounts,
                            onAdd: { amount in
                                viewModel.addWater(amount)
                                showUndoBanner(
                                    message: viewModel.undoBannerMessage
                                )
                            }
                        )
                                                
                        RecentActivitySection(
                            entries: viewModel.hydrationState.entries,
                            onDelete: { entry in
                                viewModel.deleteEntry(entry)
                                showUndoBanner(
                                    message: viewModel.undoBannerMessage
                                )
                            },
                            onOpenHistory: {
                                isHistoryPresented = true
                            }
                        )
                        
                        Spacer(minLength: AppSpacing.xl)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.xl)
                }
            }
            
            if isUndoBannerPresented {
                UndoBanner(
                    message: undoBannerMessage,
                    isVisible: isUndoBannerVisible,
                    onUndo: {
                        undoBannerDismissTask?.cancel()
                        viewModel?.undoLastAction()
                        Task {
                            await hideUndoBanner()
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $isAddWaterSheetPresented) {
            if let viewModel {
                AddWaterSheet(
                    presets: addWaterPresetAmounts,
                    onAdd: { amount, drinkType in
                        viewModel.addWater(
                            amount,
                            drinkType: drinkType
                        )
                        
                        showUndoBanner(
                            message: viewModel.undoBannerMessage
                        )
                    }
                )
            }
        }
        .navigationDestination(isPresented: $isHistoryPresented) {
            HistoryView()
        }
        .onAppear {
            setupViewModelIfNeeded()
            viewModel?.loadEntries()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            
            viewModel?.loadEntries()
        }
    }
    
    // MARK: - Setup
    
    private func setupViewModelIfNeeded() {
        guard viewModel == nil else { return }
        
        viewModel = AppFactory.makeHomeViewModel(
            context: modelContext
        )
    }
    
    // MARK: - Actions
    
    private func showUndoBanner(
        message: String
    ) {
        guard !message.isEmpty else { return }
        
        undoBannerDismissTask?.cancel()
        
        undoBannerMessage = message
        isUndoBannerPresented = true
        isUndoBannerVisible = false
        
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
