//
//  ContentView.swift
//  JustWater
//
//  Created by сонный on 10.05.2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Text("JustWater")
                .font(.largeTitle)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    HomeView()
}
