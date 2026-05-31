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
    @State private var isDatePickerPresented = false
    @State private var editorMode: WaterEntryEditorMode?
    
    @State private var isUndoBannerPresented = false
    @State private var isUndoBannerVisible = false
    @State private var undoBannerMessage = ""
    @State private var undoBannerDismissTask: Task<Void, Never>?
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView(showsIndicators: false) {
                if let viewModel {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        HistoryPeriodPicker(
                            selectedPeriod: viewModel.selectedPeriod,
                            onSelect: viewModel.selectPeriod
                        )
                        
                        HistoryPeriodNavigation(
                            title: viewModel.periodTitle,
                            onPrevious: viewModel.showPreviousPeriod,
                            onNext: viewModel.showNextPeriod,
                            onTapTitle: {
                                isDatePickerPresented = true
                            }
                        )
                        
                        if let analytics = viewModel.analytics {
                            HistoryContentView(
                                analytics: analytics,
                                dailyGoal: viewModel.displayDailyGoal,
                                onAddEntry: {
                                    editorMode = .add(
                                        date: viewModel.referenceDate
                                    )
                                },
                                onEditEntry: { entry in
                                    editorMode = .edit(
                                        entry: entry
                                    )
                                },
                                onDeleteEntry: { entry in
                                    viewModel.deleteEntry(entry)
                                    
                                    showUndoBanner(
                                        message: viewModel.undoBannerMessage
                                    )
                                }
                            )
                        }
                    }
                    .padding(AppSpacing.lg)
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
        .onAppear {
            setupViewModelIfNeeded()
            viewModel?.loadAnalytics()
        }
        .sheet(isPresented: $isDatePickerPresented) {
            if let viewModel {
                HistoryDatePickerSheet(
                    selectedDate: viewModel.referenceDate,
                    dayStatesProvider: { monthDate in
                        viewModel.calendarDayStates(
                            for: monthDate
                        )
                    },
                    onSelectDate: { date in
                        viewModel.selectReferenceDate(date)
                    }
                )
            }
        }
        .sheet(item: $editorMode) { mode in
            editorSheet(mode)
        }
        .navigationTitle(String(localized: "History"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func editorSheet(
        _ mode: WaterEntryEditorMode
    ) -> some View {
        if let viewModel {
            WaterEntryEditorSheet(
                mode: mode
            ) { amount, date, drinkType in
                handleEditorSave(
                    mode: mode,
                    amount: amount,
                    date: date,
                    drinkType: drinkType,
                    viewModel: viewModel
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleEditorSave(
        mode: WaterEntryEditorMode,
        amount: Int,
        date: Date,
        drinkType: DrinkType,
        viewModel: HistoryViewModel
    ) {
        switch mode {
        case .add:
            viewModel.addEntry(
                amount: amount,
                date: date,
                drinkType: drinkType
            )
            
            showUndoBanner(
                message: viewModel.undoBannerMessage
            )
            
        case .edit(let entry):
            viewModel.updateEntry(
                entry,
                amount: amount,
                date: date,
                drinkType: drinkType
            )
        }
    }
    
    // MARK: - Undo
    
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
    
    // MARK: - Setup
    
    private func setupViewModelIfNeeded() {
        guard viewModel == nil else { return }
        
        viewModel = AppFactory.makeHistoryViewModel(
            context: modelContext
        )
    }
}
