//
//  QuickAddSection.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct QuickAddSection: View {
    
    // MARK: - Properties
    
    let amounts: [Int]
    let onAdd: (Int) -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(amounts, id: \.self) { amount in
                QuickAddButton(amount: amount) {
                    onAdd(amount)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
