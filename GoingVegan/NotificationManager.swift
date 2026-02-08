//
//  NotificationManager.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/8/26.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
            
            if granted {
                self.scheduleStreakReminder()
            }
        }
    }
    
    func scheduleStreakReminder() {
        // Cancel existing reminder
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["streakReminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Don't break your streak! 🔥"
        content.body = "Check in today to keep your vegan streak alive"
        content.sound = .default
        content.badge = 1
        
        // Schedule for 8 PM every day
        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streakReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func sendMilestoneNotification(milestone: Milestone) {
        let content = UNMutableNotificationContent()
        content.title = milestone.title
        content.body = milestone.message
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "milestone_\(milestone.daysRequired)",
            content: content,
            trigger: nil // Send immediately
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func sendAchievementNotification(achievement: Achievement) {
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🏆"
        content.body = "\(achievement.name): \(achievement.description)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "achievement_\(achievement.id)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleDailyChallengeNotification() {
        // Cancel existing
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyChallenge"])
        
        let content = UNMutableNotificationContent()
        content.title = "New Daily Challenge! 💪"
        content.body = "Check out today's challenge and keep growing!"
        content.sound = .default
        
        // Schedule for 9 AM every day
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyChallenge", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
