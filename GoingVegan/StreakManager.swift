//
//  StreakManager.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/8/26.
//

import Foundation
import SwiftUI

class StreakManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastCheckInDate: Date?
    
    private let userDefaults = UserDefaults.standard
    private let currentStreakKey = "currentStreak"
    private let longestStreakKey = "longestStreak"
    private let lastCheckInKey = "lastCheckInDate"
    
    init() {
        loadStreak()
    }
    
    func calculateStreak(from dates: [Date]) {
        guard !dates.isEmpty else {
            currentStreak = 0
            saveStreak()
            return
        }
        
        // Sort dates in descending order
        let sortedDates = dates.sorted(by: >)
        
        // Get unique calendar days
        let calendar = Calendar.current
        let uniqueDays = Set(sortedDates.map { calendar.startOfDay(for: $0) })
        let sortedUniqueDays = uniqueDays.sorted(by: >)
        
        guard let mostRecentDay = sortedUniqueDays.first else {
            currentStreak = 0
            saveStreak()
            return
        }
        
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Check if most recent check-in was today or yesterday
        if mostRecentDay != today && mostRecentDay != yesterday {
            currentStreak = 0
            saveStreak()
            return
        }
        
        // Calculate current streak
        var streak = 0
        var currentDate = mostRecentDay
        
        for day in sortedUniqueDays {
            if day == currentDate {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else if calendar.dateComponents([.day], from: day, to: currentDate).day! > 0 {
                // Gap in streak
                break
            }
        }
        
        currentStreak = streak
        lastCheckInDate = mostRecentDay
        
        // Update longest streak
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        saveStreak()
    }
    
    func isStreakAtRisk() -> Bool {
        guard let lastCheckIn = lastCheckInDate else { return false }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastCheckInDay = calendar.startOfDay(for: lastCheckIn)
        
        // Streak is at risk if last check-in was yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        return lastCheckInDay == yesterday
    }
    
    func checkForMilestone() -> Milestone? {
        let milestones: [Milestone] = [
            .firstDay, .week, .twoWeeks, .month, .fiftyDays, 
            .hundred, .sixMonths, .year
        ]
        
        for milestone in milestones {
            if currentStreak == milestone.daysRequired {
                return milestone
            }
        }
        
        return nil
    }
    
    private func saveStreak() {
        userDefaults.set(currentStreak, forKey: currentStreakKey)
        userDefaults.set(longestStreak, forKey: longestStreakKey)
        if let lastCheckIn = lastCheckInDate {
            userDefaults.set(lastCheckIn, forKey: lastCheckInKey)
        }
    }
    
    private func loadStreak() {
        currentStreak = userDefaults.integer(forKey: currentStreakKey)
        longestStreak = userDefaults.integer(forKey: longestStreakKey)
        lastCheckInDate = userDefaults.object(forKey: lastCheckInKey) as? Date
    }
}

// MARK: - Milestone

enum Milestone: Identifiable {
    case firstDay
    case week
    case twoWeeks
    case month
    case fiftyDays
    case hundred
    case sixMonths
    case year
    
    var id: String { title }
    
    var title: String {
        switch self {
        case .firstDay: return "First Day!"
        case .week: return "One Week Strong!"
        case .twoWeeks: return "Two Weeks!"
        case .month: return "30 Days! Amazing!"
        case .fiftyDays: return "50 Days!"
        case .hundred: return "100 Days! Incredible!"
        case .sixMonths: return "6 Months! Wow!"
        case .year: return "365 Days! Life-Changing!"
        }
    }
    
    var message: String {
        switch self {
        case .firstDay: return "You've taken the first step on your vegan journey!"
        case .week: return "You've maintained your commitment for a whole week!"
        case .twoWeeks: return "Two weeks of making a difference!"
        case .month: return "You've saved 30 animals and made a real impact!"
        case .fiftyDays: return "You're halfway to 100 days!"
        case .hundred: return "100 days of compassion and sustainability!"
        case .sixMonths: return "Half a year of living your values!"
        case .year: return "You've changed the world for an entire year!"
        }
    }
    
    var icon: String {
        switch self {
        case .firstDay: return "star.fill"
        case .week: return "flame.fill"
        case .twoWeeks: return "bolt.fill"
        case .month: return "heart.fill"
        case .fiftyDays: return "sparkles"
        case .hundred: return "trophy.fill"
        case .sixMonths: return "crown.fill"
        case .year: return "medal.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .firstDay: return .yellow
        case .week: return .orange
        case .twoWeeks: return .pink
        case .month: return .red
        case .fiftyDays: return .purple
        case .hundred: return .blue
        case .sixMonths: return .indigo
        case .year: return .green
        }
    }
    
    var daysRequired: Int {
        switch self {
        case .firstDay: return 1
        case .week: return 7
        case .twoWeeks: return 14
        case .month: return 30
        case .fiftyDays: return 50
        case .hundred: return 100
        case .sixMonths: return 182
        case .year: return 365
        }
    }
}
