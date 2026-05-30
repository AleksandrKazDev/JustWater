//
//  NotificationService.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import Foundation
import UserNotifications
import UIKit

@MainActor
protocol NotificationServicing {
    
    func requestAuthorization() async -> Bool
    
    func getAuthorizationStatus() async -> UNAuthorizationStatus
    
    func openAppNotificationSettings()
    
    func scheduleHydrationReminders(
        startHour: Int,
        endHour: Int,
        frequency: ReminderFrequency
    ) async
    
    func cancelHydrationReminders()
    
    //    #if DEBUG
    //    func scheduleTestNotificationInFiveSeconds() async
    //    #endif
}

@MainActor
final class AppNotificationService: NotificationServicing {
    
    // MARK: - Constants
    
    private let reminderIdentifierPrefix = "hydration-reminder-"
    
    // MARK: - Dependencies
    
    private let errorReporter: ErrorReporting
    
    // MARK: - Initializer
    
    init(
        errorReporter: ErrorReporting
    ) {
        self.errorReporter = errorReporter
    }
    
    // MARK: - Public Methods
    
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound]
            )
        } catch {
            errorReporter.report(
                error,
                context: "Failed to request notification authorization"
            )
            
            return false
        }
    }
    
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    func openAppNotificationSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func scheduleHydrationReminders(
        startHour: Int,
        endHour: Int,
        frequency: ReminderFrequency
    ) async {
        cancelHydrationReminders()
        
        guard startHour < endHour else {
            return
        }
        
        let hours = Array(
            stride(
                from: startHour,
                to: endHour,
                by: frequency.rawValue
            )
        )
        
        let reminderBodyKeys = HydrationReminderMessageProvider.shuffledBodyKeys(
            count: hours.count
        )
        
        for (index, hour) in hours.enumerated() {
            await scheduleReminder(
                hour: hour,
                bodyLocalizationKey: reminderBodyKeys[index]
            )
        }
    }
    
    func cancelHydrationReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: reminderIdentifiers
        )
    }
    
    //    #if DEBUG
    //    func scheduleTestNotificationInFiveSeconds() async {
    //        let content = UNMutableNotificationContent()
    //    content.title = NSString.localizedUserNotificationString(
    //        forKey: "notification.test.title",
    //        arguments: nil
    //    )
    //    content.body = NSString.localizedUserNotificationString(
    //        forKey: "notification.test.body",
    //        arguments: nil
    //    )
    //        content.sound = .default
    //
    //        let trigger = UNTimeIntervalNotificationTrigger(
    //            timeInterval: 5,
    //            repeats: false
    //        )
    //
    //        let request = UNNotificationRequest(
    //            identifier: "hydration-test-notification",
    //            content: content,
    //            trigger: trigger
    //        )
    //
    //        do {
    //            try await UNUserNotificationCenter.current().add(request)
    //        } catch {
    //            errorReporter.report(
    //                error,
    //                context: "Failed to schedule test notification"
    //            )
    //        }
    //    }
    //    #endif
    
    // MARK: - Private Properties
    
    private var reminderIdentifiers: [String] {
        (0...23).map {
            "\(reminderIdentifierPrefix)\($0)"
        }
    }
    
    // MARK: - Private Methods
    
    private func scheduleReminder(
        hour: Int,
        bodyLocalizationKey: String
    ) async {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(
            forKey: HydrationReminderMessageProvider.titleKey,
            arguments: nil
        )
        content.body = NSString.localizedUserNotificationString(
            forKey: bodyLocalizationKey,
            arguments: nil
        )
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "\(reminderIdentifierPrefix)\(hour)",
            content: content,
            trigger: trigger
        )
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            errorReporter.report(
                error,
                context: "Failed to schedule reminder at \(hour):00"
            )
        }
    }
}
