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
            storageService: storageService,
            hapticService: makeHapticService(),
            errorReporter: makeErrorReporter()
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
            goalStorageService: goalStorageService,
            hapticService: makeHapticService(),
            errorReporter: makeErrorReporter()
        )
    }
    
    static func makeSettingsViewModel(
        context: ModelContext
    ) -> SettingsViewModel {
        let goalStorageService = makeWaterGoalStorageService(
            context: context
        )
        
        let dailyGoalUpdateService = DailyGoalUpdateService(
            goalStorageService: goalStorageService
        )
        
        let errorReporter = makeErrorReporter()
        
        return SettingsViewModel(
            goalStorageService: goalStorageService,
            dailyGoalUpdateService: dailyGoalUpdateService,
            notificationService: makeNotificationService(
                errorReporter: errorReporter
            ),
            errorReporter: errorReporter
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
    
    static func makeDailyGoalUpdateService(
        context: ModelContext
    ) -> DailyGoalUpdateService {
        DailyGoalUpdateService(
            goalStorageService: makeWaterGoalStorageService(
                context: context
            )
        )
    }
    
    private static func makeHapticService() -> HapticServicing {
        AppHapticService()
    }
    
    static func makeErrorReporter() -> ErrorReporting {
        AppErrorReporter()
    }
    
    private static func makeNotificationService(
        errorReporter: ErrorReporting
    ) -> NotificationServicing {
        AppNotificationService(
            errorReporter: errorReporter
        )
    }
}
