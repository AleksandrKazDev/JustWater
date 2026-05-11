//
//  File.swift
//  JustWater
//
//  Created by сонный on 11.05.2026.
//

import Foundation
import SwiftUI

@Observable
final class AppCoordinator {
    
    var selectedTab: AppTab = .home
}

enum AppTab {
    case home
    case calculator
    case insights
    case settings
}
