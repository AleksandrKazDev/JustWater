//
//  HomeUndoBanner.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftUI

struct HomeUndoBanner: View {
    
    // MARK: - Properties
    
    let isVisible: Bool
    let onUndo: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Text("Water added")
                    .font(AppTypography.body)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button("Undo") {
                    onUndo()
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
            .opacity(isVisible ? 1 : 0)
            .allowsHitTesting(isVisible)
        }
    }
}
