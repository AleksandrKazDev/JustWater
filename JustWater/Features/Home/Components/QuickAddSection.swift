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
    let measurementUnit: MeasurementUnit
    let onAdd: (Int) -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(amounts, id: \.self) { amount in
                QuickAddButton(
                    amount: amount,
                    measurementUnit: measurementUnit
                ) {
                    onAdd(amount)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
