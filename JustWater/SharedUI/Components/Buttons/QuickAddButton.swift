//
//  QuickAddButton.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import SwiftUI

struct QuickAddButton: View {
    
    let amount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("+\(amount) ml")
                .font(AppTypography.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .foregroundStyle(AppColors.deepBlue)
                .frame(minWidth: 92)
                .frame(height: 40)
                .background {
                    Capsule()
                        .fill(AppColors.lightBlue.opacity(0.35))
                        .overlay {
                            Capsule()
                                .stroke(AppColors.border, lineWidth: 1)
                        }
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        HStack {
            QuickAddButton(amount: 100) {}
            QuickAddButton(amount: 200) {}
            QuickAddButton(amount: 300) {}
        }
    }
}
