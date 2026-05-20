//
//  HistoryPeriodNavigation.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HistoryPeriodNavigation: View {
    
    // MARK: - Properties
    
    let title: String
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onTapTitle: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Button {
                onPrevious()
            } label: {
                navigationIcon("chevron.left")
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button {
                onTapTitle()
            } label: {
                Text(title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button {
                onNext()
            } label: {
                navigationIcon("chevron.right")
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Components
    
    private func navigationIcon(
        _ systemImage: String
    ) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(AppColors.primaryText)
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .fill(AppColors.cardBackground)
            }
    }
}
