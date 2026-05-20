//
//  DrinkTypeSelector.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct DrinkTypeSelector: View {
    
    // MARK: - Binding
    
    @Binding var selectedDrinkType: DrinkType
    
    // MARK: - Properties
    
    let title: String
    
    // MARK: - Initializer
    
    init(
        title: String = "Drink Type",
        selectedDrinkType: Binding<DrinkType>
    ) {
        self.title = title
        self._selectedDrinkType = selectedDrinkType
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(DrinkType.allCases) { drinkType in
                        drinkTypeButton(drinkType)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
    
    // MARK: - Components
    
    private func drinkTypeButton(
        _ drinkType: DrinkType
    ) -> some View {
        Button {
            selectedDrinkType = drinkType
            HapticService.selection()
        } label: {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: drinkType.systemImage)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(drinkType.title)
                    .font(AppTypography.caption)
            }
            .foregroundStyle(
                selectedDrinkType == drinkType
                ? .white
                : AppColors.primaryText
            )
            .padding(.horizontal, AppSpacing.md)
            .frame(height: 38)
            .background {
                Capsule()
                    .fill(
                        selectedDrinkType == drinkType
                        ? AppColors.primaryBlue
                        : AppColors.cardBackground
                    )
            }
            .overlay {
                Capsule()
                    .stroke(
                        selectedDrinkType == drinkType
                        ? AppColors.primaryBlue.opacity(0)
                        : AppColors.border,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
