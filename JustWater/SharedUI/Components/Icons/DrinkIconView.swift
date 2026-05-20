//
//  DrinkIconView.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct DrinkIconView: View {
    
    // MARK: - Properties
    
    let drinkType: DrinkType
    let size: CGFloat
    
    // MARK: - Initializer
    
    init(
        drinkType: DrinkType,
        size: CGFloat = 32
    ) {
        self.drinkType = drinkType
        self.size = size
    }
    
    // MARK: - Body
    
    var body: some View {
        Image(systemName: drinkType.systemImage)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundStyle(drinkType.tintColor)
            .frame(width: size, height: size)
            .background {
                Circle()
                    .fill(drinkType.tintColor.opacity(0.18))
            }
    }
    
    // MARK: - Computed Properties
    
    private var iconSize: CGFloat {
        max(size * 0.44, 12)
    }
}
