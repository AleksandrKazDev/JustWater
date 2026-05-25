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
        
        let goalStorageService = makeWaterGoalStorageService(
            context: context
        )
        
        return HistoryViewModel(
            storageService: storageService,
            goalStorageService: goalStorageService
        )
    }
    
    static func makeSettingsViewModel(
        context: ModelContext
    ) -> SettingsViewModel {
        let goalStorageService = makeWaterGoalStorageService(
            context: context
        )
        
        return SettingsViewModel(
            goalStorageService: goalStorageService
        )
    }
    
    private static func makeWaterStorageService(
        context: ModelContext
    ) -> WaterStorageService {
        WaterStorageService(
            context: context
        )
    }
    
    private static func makeWaterGoalStorageService(
        context: ModelContext
    ) -> WaterGoalStorageService {
        WaterGoalStorageService(
            context: context
        )
    }
}
