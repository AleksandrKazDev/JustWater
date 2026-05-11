//
//  RootView.swift
//  JustWater
//
//  Created by сонный on 11.05.2026.
//

import SwiftUI

struct RootView: View {
    
    @State private var coordinator = AppCoordinator()
    
    var body: some View {
        HomeView()
            .environment(coordinator)
    }
}

#Preview {
    RootView()
}
