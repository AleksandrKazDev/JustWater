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
//    func debugPrintPendingNotifications() async
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
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(
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
        let settings = await UNUserNotificationCenter.current()
            .notificationSettings()
        
        return settings.authorizationStatus
    }
    
    func openAppNotificationSettings() {
        guard let url = URL(
            string: UIApplication.openSettingsURLString
        ) else {
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
        
        guard frequency.rawValue > 0 else {
            errorReporter.report(
                NotificationServiceError.invalidReminderFrequency,
                context: "Invalid reminder frequency: \(frequency.rawValue)"
            )
            
            return
        }
        
        let hours = reminderHours(
            startHour: startHour,
            endHour: endHour,
            frequency: frequency
        )
        
        guard !hours.isEmpty else {
            errorReporter.report(
                NotificationServiceError.emptyReminderHours,
                context: "No reminder hours generated"
            )
            
            return
        }
        
        let reminderBodies = HydrationReminderMessageProvider.shuffledBodies(
            count: hours.count
        )
        
        for (index, hour) in hours.enumerated() {
            await scheduleReminder(
                hour: hour,
                body: reminderBodies[index]
            )
        }
//        
//        #if DEBUG
//        await debugPrintPendingNotifications()
//        #endif
    }
    
    func cancelHydrationReminders() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: reminderIdentifiers
            )
    }
    
//    #if DEBUG
//    func scheduleTestNotificationInFiveSeconds() async {
//        let content = UNMutableNotificationContent()
//        content.title = String(localized: "notification.test.title")
//        content.body = String(localized: "notification.test.body")
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
//            try await UNUserNotificationCenter.current()
//                .add(request)
//        } catch {
//            errorReporter.report(
//                error,
//                context: "Failed to schedule test notification"
//            )
//        }
//    }
//    
//    func debugPrintPendingNotifications() async {
//        let requests = await UNUserNotificationCenter.current()
//            .pendingNotificationRequests()
//        
//        print("🔔 Pending notifications count:", requests.count)
//        
//        for request in requests {
//            print("🔔 ID:", request.identifier)
//            print("🔔 Title:", request.content.title)
//            print("🔔 Body:", request.content.body)
//            
//            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
//                print("🔔 Next trigger:", String(describing: trigger.nextTriggerDate()))
//            } else {
//                print("🔔 Trigger:", String(describing: request.trigger))
//            }
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
        body: String
    ) async {
        let content = UNMutableNotificationContent()
        content.title = HydrationReminderMessageProvider.title()
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = normalizedHour(hour)
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "\(reminderIdentifierPrefix)\(normalizedHour(hour))",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current()
                .add(request)
        } catch {
            errorReporter.report(
                error,
                context: "Failed to schedule reminder at \(hour):00"
            )
        }
    }
    
    private func reminderHours(
        startHour: Int,
        endHour: Int,
        frequency: ReminderFrequency
    ) -> [Int] {
        let startHour = normalizedHour(startHour)
        let endHour = normalizedHour(endHour)
        let step = frequency.rawValue
        
        let fullDayHours: [Int]
        
        if startHour <= endHour {
            fullDayHours = Array(startHour...endHour)
        } else {
            fullDayHours = Array(startHour...23) + Array(0...endHour)
        }
        
        return fullDayHours.enumerated().compactMap { index, hour in
            index.isMultiple(of: step) ? hour : nil
        }
    }
    
    private func normalizedHour(
        _ hour: Int
    ) -> Int {
        min(
            max(hour, 0),
            23
        )
    }
}

// MARK: - NotificationServiceError

private enum NotificationServiceError: LocalizedError {
    case invalidReminderFrequency
    case emptyReminderHours
    
    var errorDescription: String? {
        switch self {
        case .invalidReminderFrequency:
            return "Reminder frequency must be greater than zero."
            
        case .emptyReminderHours:
            return "Reminder schedule did not generate any hours."
        }
    }
}
