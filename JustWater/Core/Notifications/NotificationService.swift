//
//  NotificationService.swift
//  JustWater
//
//  Created by сонный on 21.05.2026.
//

import Foundation
import UserNotifications
import UIKit

enum NotificationService {
    
    // MARK: - Constants
    
    private static let reminderIdentifierPrefix = "hydration-reminder-"
    
    // MARK: - Public Methods
    
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound]
            )
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    static func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    static func openAppNotificationSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    static func scheduleHydrationReminders(
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
        
        for hour in hours {
            await scheduleReminder(hour: hour)
        }
    }
    
    static func cancelHydrationReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: reminderIdentifiers
        )
    }
    
#if DEBUG
static func scheduleTestNotificationInFiveSeconds() async {
    let content = UNMutableNotificationContent()
    content.title = "Test reminder"
    content.body = "This is a JustWater test notification."
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(
        timeInterval: 5,
        repeats: false
    )
    
    let request = UNNotificationRequest(
        identifier: "hydration-test-notification",
        content: content,
        trigger: trigger
    )
    
    do {
        try await UNUserNotificationCenter.current().add(request)
    } catch {
        print("Failed to schedule test notification: \(error)")
    }
}
#endif
    
    // MARK: - Private Properties
    
    private static var reminderIdentifiers: [String] {
        (0...23).map {
            "\(reminderIdentifierPrefix)\($0)"
        }
    }
    
    // MARK: - Private Methods
    
    private static func scheduleReminder(
        hour: Int
    ) async {
        let content = UNMutableNotificationContent()
        content.title = "Time to hydrate"
        content.body = "Take a moment to drink some water."
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
            print("Failed to schedule reminder at \(hour):00 - \(error)")
        }
    }
}
