//
//  AppFactory.swift
//  JustWater
//
//  Created by сонный on 20.05.2026.
//

import SwiftData

@MainActor
enum AppFactory {
    
    static func makeHomeViewModel(
        context: ModelContext
    ) -> HomeViewModel {
        let storageService = makeWaterStorageService(
            context: context
        )
        
        return HomeViewModel(
            storageService: storageService
        )
    }
    
    static func makeHistoryViewModel(
        context: ModelContext
    ) -> HistoryViewModel {
        let storageService = makeWaterStorageService(
            context: context
        )
        
        return HistoryViewModel(
            storageService: storageService
        )
    }
    
    private static func makeWaterStorageService(
        context: ModelContext
    ) -> WaterStorageService {
        WaterStorageService(
            context: context
        )
    }
}
