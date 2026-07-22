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
        
        let streakDayService = makeHydrationStreakDayService(
            context: context
        )
        
        let errorReporter = makeErrorReporter()
        
        return HomeViewModel(
            storageService: storageService,
            streakDayService: streakDayService,
            hapticService: makeHapticService(),
            errorReporter: errorReporter,
            widgetSnapshotService: WidgetSnapshotService(),
            healthSyncService: makeHealthSyncService(
                errorReporter: errorReporter
            ),
            goalAchievementService: GoalAchievementService()
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
        
        let streakDayService = makeHydrationStreakDayService(
            context: context
        )
        
        let errorReporter = makeErrorReporter()
        
        return HistoryViewModel(
            storageService: storageService,
            goalStorageService: goalStorageService,
            streakDayService: streakDayService,
            streakCalculator: HydrationStreakCalculator(),
            dateProvider: SystemDateProvider(),
            hapticService: makeHapticService(),
            errorReporter: makeErrorReporter(),
            healthSyncService: makeHealthSyncService(
                errorReporter: errorReporter
            ),
            goalAchievementService: GoalAchievementService()
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
            backupExportService: makeBackupExportService(
                context: context
            ),
            backupImportService: makeBackupImportService(),
            backupRestoreService: makeBackupRestoreService(
                modelContainer: context.container
            ),
            notificationService: makeNotificationService(
                errorReporter: errorReporter
            ),
            healthKitService: makeHealthKitService(),
            errorReporter: errorReporter
        )
    }
    
    static func makeBackupExportService(
        context: ModelContext
    ) -> BackupExportService {
        BackupExportService(
            context: context
        )
    }

    private static func makeBackupImportService() -> BackupImportService {
        BackupImportService()
    }

    private static func makeBackupRestoreService(
        modelContainer: ModelContainer
    ) -> BackupRestoreService {
        BackupRestoreService(
            modelContainer: modelContainer
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
    
    private static func makeHydrationStreakDayService(
        context: ModelContext
    ) -> HydrationStreakDayService {
        HydrationStreakDayService(
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
    
    private static func makeHealthKitService() -> HealthKitServicing {
        HealthKitService()
    }
    
    private static func makeHealthSyncService(
        errorReporter: ErrorReporting
    ) -> HealthSyncServicing {
        HealthSyncService(
            healthKitService: makeHealthKitService(),
            errorReporter: errorReporter
        )
    }
}
