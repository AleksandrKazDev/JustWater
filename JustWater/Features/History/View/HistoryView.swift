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
                                dailyGoal: AppSettingsStorage.dailyGoal,
                                onAddEntry: {
                                    editorMode = .add(
                                        date: viewModel.referenceDate
                                    )
                                },
                                onEditEntry: { entry in
                                    editorMode = .edit(entry: entry)
                                },
                                onDeleteEntry: viewModel.deleteEntry
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
                HistoryDatePickerSheet(
                    selectedDate: viewModel.referenceDate,
                    onSelectDate: viewModel.selectReferenceDate
                )
            }
        }
        .sheet(item: $editorMode) { mode in
            editorSheet(mode)
        }
        .navigationTitle("History")
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
            
        case .edit(let entry):
            viewModel.updateEntry(
                entry,
                amount: amount,
                date: date,
                drinkType: drinkType
            )
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
