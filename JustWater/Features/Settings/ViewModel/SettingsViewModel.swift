//
//  SettingsViewModel.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import SwiftUI
import Observation
import UserNotifications

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Dependencies
    
    private let goalStorageService: WaterGoalStorageServicing
    private let dailyGoalUpdateService: DailyGoalUpdating
    private let backupExportService: BackupExportServicing
    private let backupImportService: BackupImportServicing
    private let backupRestoreService: BackupRestoreServicing
    private let notificationService: NotificationServicing
    private let healthKitService: HealthKitServicing
    private let errorReporter: ErrorReporting
    @ObservationIgnored private var hasLoadedSettings = false
    @ObservationIgnored private var latestRemindersRequestID: UUID?
    @ObservationIgnored private var latestHealthSyncRequestID: UUID?
    
    // MARK: - Properties
    
    var dailyGoal: Int
    var isHapticsEnabled: Bool
    var appearanceMode: AppAppearanceMode
    var measurementUnit: MeasurementUnit
    
    var areRemindersEnabled: Bool
    var reminderStartHour: Int
    var reminderEndHour: Int
    var reminderFrequency: ReminderFrequency
    var notificationAuthorizationStatus: UNAuthorizationStatus
    var isHealthSyncEnabled: Bool = AppSettingsStorage.isHealthSyncEnabled
    
    // MARK: - Computed Properties
    
    var isNotificationPermissionDenied: Bool {
        notificationAuthorizationStatus == .denied
    }
    
    var reminderScheduleTitle: String {
        "\(formattedHour(reminderStartHour)) – \(formattedHour(reminderEndHour))"
    }
    
    // MARK: - Initializer
    
    init(
        goalStorageService: WaterGoalStorageServicing,
        dailyGoalUpdateService: DailyGoalUpdating,
        backupExportService: BackupExportServicing,
        backupImportService: BackupImportServicing,
        backupRestoreService: BackupRestoreServicing,
        notificationService: NotificationServicing,
        healthKitService: HealthKitServicing,
        errorReporter: ErrorReporting
    ) {
        self.goalStorageService = goalStorageService
        self.dailyGoalUpdateService = dailyGoalUpdateService
        self.backupExportService = backupExportService
        self.backupImportService = backupImportService
        self.backupRestoreService = backupRestoreService
        self.notificationService = notificationService
        self.errorReporter = errorReporter
        
        self.dailyGoal = AppSettingsStorage.dailyGoal
        self.isHapticsEnabled = AppSettingsStorage.isHapticsEnabled
        self.appearanceMode = AppSettingsStorage.appearanceMode
        self.measurementUnit = AppSettingsStorage.measurementUnit
        
        self.areRemindersEnabled = AppSettingsStorage.areRemindersEnabled
        self.reminderStartHour = AppSettingsStorage.reminderStartHour
        self.reminderEndHour = AppSettingsStorage.reminderEndHour
        self.reminderFrequency = AppSettingsStorage.reminderFrequency
        self.notificationAuthorizationStatus = .notDetermined
        self.healthKitService = healthKitService
        
    }
    
    // MARK: - Public Methods

    func createBackup() throws -> BackupExportResult {
        do {
            return try backupExportService.createBackup()
        } catch {
            errorReporter.report(
                error,
                context: "Failed to create backup"
            )

            throw error
        }
    }

    func prepareBackupImport(
        from url: URL
    ) async throws -> PreparedBackupImport {
        do {
            return try await backupImportService.prepareImport(
                from: url
            )
        } catch {
            guard !(error is CancellationError) else {
                throw error
            }

            errorReporter.report(
                error,
                context: "Failed to prepare backup import"
            )

            throw error
        }
    }

    func mergeBackup(
        _ preparedImport: PreparedBackupImport
    ) async throws -> MergeRestoreResult {
        do {
            let result = try await backupRestoreService.mergeRestore(
                preparedImport
            )

            updateIfNeeded(
                \.dailyGoal,
                to: AppSettingsStorage.dailyGoal
            )

            return result
        } catch {
            guard !(error is CancellationError) else {
                throw error
            }

            errorReporter.report(
                error,
                context: "Failed to merge backup"
            )

            throw error
        }
    }

    func replaceBackup(
        _ preparedImport: PreparedBackupImport
    ) async throws -> ReplaceRestoreResult {
        do {
            let result = try await backupRestoreService.replaceRestore(
                preparedImport
            )

            updateIfNeeded(
                \.dailyGoal,
                to: result.currentDailyGoal
            )

            return result
        } catch {
            guard !(error is CancellationError) else {
                throw error
            }

            errorReporter.report(
                error,
                context: "Failed to replace backup"
            )

            throw error
        }
    }

    func reportBackupFileSaveError(
        _ error: Error
    ) {
        errorReporter.report(
            error,
            context: "Failed to save backup file"
        )
    }

    func reportBackupFileSelectionError(
        _ error: Error
    ) {
        errorReporter.report(
            error,
            context: "Failed to select backup file"
        )
    }
    
    func updateDailyGoal(
        _ goal: Int
    ) {
        do {
            try dailyGoalUpdateService.updateDailyGoal(goal)
            updateIfNeeded(\.dailyGoal, to: goal)
        } catch {
            errorReporter.report(
                error,
                context: "Failed to update daily goal"
            )
        }
    }
    
    func updateHapticsEnabled(
        _ isEnabled: Bool
    ) {
        if AppSettingsStorage.isHapticsEnabled != isEnabled {
            AppSettingsStorage.isHapticsEnabled = isEnabled
        }
        
        updateIfNeeded(\.isHapticsEnabled, to: isEnabled)
    }
    
    func updateAppearanceMode(
        _ mode: AppAppearanceMode
    ) {
        guard appearanceMode != mode else { return }
        
        AppSettingsStorage.appearanceMode = mode
        updateIfNeeded(\.appearanceMode, to: mode)
        
        NotificationCenter.default.post(
            name: .appAppearanceDidChange,
            object: nil
        )
    }
    
    func updateMeasurementUnit(
        _ unit: MeasurementUnit
    ) {
        if AppSettingsStorage.measurementUnit != unit {
            AppSettingsStorage.measurementUnit = unit
        }
        
        updateIfNeeded(\.measurementUnit, to: unit)
    }
    
    func updateReminderStartHour(
        _ hour: Int
    ) {
        guard reminderStartHour != hour else { return }
        
        updateIfNeeded(\.reminderStartHour, to: hour)
        AppSettingsStorage.reminderStartHour = hour
        
        Task {
            await rescheduleRemindersIfNeeded()
        }
    }
    
    func updateReminderEndHour(
        _ hour: Int
    ) {
        guard reminderEndHour != hour else { return }
        
        updateIfNeeded(\.reminderEndHour, to: hour)
        AppSettingsStorage.reminderEndHour = hour
        
        Task {
            await rescheduleRemindersIfNeeded()
        }
    }
    
    func updateReminderFrequency(
        _ frequency: ReminderFrequency
    ) {
        guard reminderFrequency != frequency else { return }
        
        updateIfNeeded(\.reminderFrequency, to: frequency)
        AppSettingsStorage.reminderFrequency = frequency
        
        Task {
            await rescheduleRemindersIfNeeded()
        }
    }
    
    func setRemindersEnabled(
        _ isEnabled: Bool
    ) {
        let requestID = UUID()
        latestRemindersRequestID = requestID

        Task {
            await updateRemindersEnabled(
                isEnabled,
                requestID: requestID
            )
        }
    }
    
    func refreshNotificationAuthorizationStatus() {
        Task {
            let status = await notificationService.getAuthorizationStatus()
            updateIfNeeded(\.notificationAuthorizationStatus, to: status)
            
            if status == .denied {
                updateIfNeeded(\.areRemindersEnabled, to: false)
                
                if AppSettingsStorage.areRemindersEnabled {
                    AppSettingsStorage.areRemindersEnabled = false
                }
                
                notificationService.cancelHydrationReminders()
            }
        }
    }
    
    func openNotificationSettings() {
        notificationService.openAppNotificationSettings()
    }
    
//    #if DEBUG
//    func scheduleTestNotificationInFiveSeconds() async {
//        await notificationService.scheduleTestNotificationInFiveSeconds()
//    }
//    #endif
    
    func setHealthSyncEnabled(
        _ isEnabled: Bool
    ) {
        let requestID = UUID()
        latestHealthSyncRequestID = requestID

        Task {
            await updateHealthSyncEnabled(
                isEnabled,
                requestID: requestID
            )
        }
    }
    
    func reloadIfNeeded() {
        guard !hasLoadedSettings else { return }
        hasLoadedSettings = true
        
        reload()
    }
    
    func reload() {
        syncCurrentGoal()
        updateIfNeeded(\.isHapticsEnabled, to: AppSettingsStorage.isHapticsEnabled)
        updateIfNeeded(\.appearanceMode, to: AppSettingsStorage.appearanceMode)
        updateIfNeeded(\.measurementUnit, to: AppSettingsStorage.measurementUnit)
        updateIfNeeded(\.isHealthSyncEnabled, to: AppSettingsStorage.isHealthSyncEnabled)
        
        updateIfNeeded(\.areRemindersEnabled, to: AppSettingsStorage.areRemindersEnabled)
        updateIfNeeded(\.reminderStartHour, to: AppSettingsStorage.reminderStartHour)
        updateIfNeeded(\.reminderEndHour, to: AppSettingsStorage.reminderEndHour)
        updateIfNeeded(\.reminderFrequency, to: AppSettingsStorage.reminderFrequency)
        
        
        refreshNotificationAuthorizationStatus()
    }
    
    // MARK: - Private Methods
    
    private func updateRemindersEnabled(
        _ isEnabled: Bool,
        requestID: UUID
    ) async {
        guard latestRemindersRequestID == requestID else {
            return
        }

        if isEnabled {
            let status = await notificationService.getAuthorizationStatus()

            guard latestRemindersRequestID == requestID else {
                return
            }

            updateIfNeeded(\.notificationAuthorizationStatus, to: status)
            
            let isAuthorized: Bool
            
            switch status {
            case .authorized, .provisional, .ephemeral:
                isAuthorized = true
                
            case .notDetermined:
                isAuthorized = await notificationService.requestAuthorization()

                guard latestRemindersRequestID == requestID else {
                    return
                }

                let updatedStatus = await notificationService.getAuthorizationStatus()

                guard latestRemindersRequestID == requestID else {
                    return
                }

                updateIfNeeded(\.notificationAuthorizationStatus, to: updatedStatus)
                
            case .denied:
                isAuthorized = false
                
            @unknown default:
                isAuthorized = false
            }
            
            guard isAuthorized else {
                updateIfNeeded(\.areRemindersEnabled, to: false)
                
                if AppSettingsStorage.areRemindersEnabled {
                    AppSettingsStorage.areRemindersEnabled = false
                }
                
                notificationService.cancelHydrationReminders()
                return
            }

            guard latestRemindersRequestID == requestID else {
                return
            }
            
            updateIfNeeded(\.areRemindersEnabled, to: true)
            
            if !AppSettingsStorage.areRemindersEnabled {
                AppSettingsStorage.areRemindersEnabled = true
            }
            
            await scheduleReminders()
        } else {
            updateIfNeeded(\.areRemindersEnabled, to: false)
            
            if AppSettingsStorage.areRemindersEnabled {
                AppSettingsStorage.areRemindersEnabled = false
            }
            
            notificationService.cancelHydrationReminders()
        }
    }
    
    private func rescheduleRemindersIfNeeded() async {
        guard areRemindersEnabled else {
            return
        }
        
        await scheduleReminders()
    }
    
    private func scheduleReminders() async {
        await notificationService.scheduleHydrationReminders(
            startHour: reminderStartHour,
            endHour: reminderEndHour,
            frequency: reminderFrequency
        )
    }
    
    private func formattedHour(
        _ hour: Int
    ) -> String {
        String(format: "%02d:00", hour)
    }
    
    private func syncCurrentGoal() {
        do {
            let currentGoal = try goalStorageService.currentGoal()
            
            if AppSettingsStorage.dailyGoal != currentGoal {
                AppSettingsStorage.dailyGoal = currentGoal
            }
            
            updateIfNeeded(\.dailyGoal, to: currentGoal)
        } catch {
            errorReporter.report(
                error,
                context: "Failed to sync current goal"
            )
        }
    }
    
    private func updateHealthSyncEnabled(
        _ isEnabled: Bool,
        requestID: UUID
    ) async {
        guard latestHealthSyncRequestID == requestID else {
            return
        }

        guard isHealthSyncEnabled != isEnabled else {
            return
        }
        
        if isEnabled {
            do {
                try await healthKitService.requestAuthorization()

                guard latestHealthSyncRequestID == requestID else {
                    return
                }
                
                if !AppSettingsStorage.isHealthSyncEnabled {
                    AppSettingsStorage.isHealthSyncEnabled = true
                }
                
                updateIfNeeded(\.isHealthSyncEnabled, to: true)
            } catch {
                guard latestHealthSyncRequestID == requestID else {
                    return
                }

                if AppSettingsStorage.isHealthSyncEnabled {
                    AppSettingsStorage.isHealthSyncEnabled = false
                }
                
                updateIfNeeded(\.isHealthSyncEnabled, to: false)
                
                errorReporter.report(
                    error,
                    context: "Failed to enable Apple Health sync"
                )
            }
        } else {
            if AppSettingsStorage.isHealthSyncEnabled {
                AppSettingsStorage.isHealthSyncEnabled = false
            }
            
            updateIfNeeded(\.isHealthSyncEnabled, to: false)
        }
    }
    
    private func updateIfNeeded<Value: Equatable>(
        _ keyPath: ReferenceWritableKeyPath<SettingsViewModel, Value>,
        to newValue: Value
    ) {
        guard self[keyPath: keyPath] != newValue else { return }
        
        self[keyPath: keyPath] = newValue
    }
}
