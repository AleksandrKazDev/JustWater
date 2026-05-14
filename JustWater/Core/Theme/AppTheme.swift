//
//  AppColors.swift
//  JustWater
//
//  Created by сонный on 14.05.2026.
//

import Foundation
import SwiftUI

enum AppColors {
    static let background = Color("Background")
    static let cardBackground = Color("CardBackground")

    static let primaryBlue = Color("PrimaryBlue")
    static let lightBlue = Color("LightBlue")
    static let deepBlue = Color("DeepBlue")

    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")
    static let border = Color("Border")
}

enum AppRadius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 18
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let pill: CGFloat = 999
}

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum AppTypography {
    static let largeTitle = Font.system(size: 40, weight: .bold, design: .default)
    static let title = Font.system(size: 28, weight: .semibold, design: .default)
    static let headline = Font.system(size: 20, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let caption = Font.system(size: 13, weight: .medium, design: .default)
}
