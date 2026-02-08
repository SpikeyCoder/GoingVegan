//
//  ChallengeManager.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/8/26.
//

import Foundation
import SwiftUI

class ChallengeManager: ObservableObject {
    @Published var todaysChallenge: Challenge?
    @Published var completedCount: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let lastChallengeKey = "lastChallengeDate"
    private let completedCountKey = "completedChallengesCount"
    
    init() {
        loadProgress()
        generateTodaysChallenge()
    }
    
    func generateTodaysChallenge() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we already have today's challenge
        if let lastDate = userDefaults.object(forKey: lastChallengeKey) as? Date,
           calendar.isDate(lastDate, inSameDayAs: today),
           let savedChallengeId = userDefaults.string(forKey: "todaysChallengeId"),
           let challenge = allChallenges.first(where: { $0.id == savedChallengeId }) {
            todaysChallenge = challenge
            return
        }
        
        // Generate new challenge for today
        let seed = today.timeIntervalSince1970
        var generator = SeededRandomNumberGenerator(seed: UInt64(seed))
        
        if let challenge = allChallenges.randomElement(using: &generator) {
            todaysChallenge = challenge
            userDefaults.set(today, forKey: lastChallengeKey)
            userDefaults.set(challenge.id, forKey: "todaysChallengeId")
            userDefaults.set(false, forKey: "todaysChallengeCompleted")
        }
    }
    
    func completeChallenge() {
        guard let challenge = todaysChallenge, !challenge.isCompleted else { return }
        
        todaysChallenge?.isCompleted = true
        completedCount += 1
        
        userDefaults.set(true, forKey: "todaysChallengeCompleted")
        userDefaults.set(completedCount, forKey: completedCountKey)
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func loadProgress() {
        completedCount = userDefaults.integer(forKey: completedCountKey)
        
        if let isCompleted = userDefaults.object(forKey: "todaysChallengeCompleted") as? Bool {
            todaysChallenge?.isCompleted = isCompleted
        }
    }
    
    private let allChallenges: [Challenge] = [
        Challenge(
            id: "try-recipe",
            title: "Try a new vegan recipe",
            icon: "frying.pan.fill",
            color: .orange,
            category: .cooking
        ),
        Challenge(
            id: "find-restaurant",
            title: "Find a vegan restaurant near you",
            icon: "map.fill",
            color: .blue,
            category: .exploration
        ),
        Challenge(
            id: "share-meal",
            title: "Share a photo of your vegan meal",
            icon: "camera.fill",
            color: .purple,
            category: .social
        ),
        Challenge(
            id: "learn-fact",
            title: "Learn about animal agriculture impact",
            icon: "book.fill",
            color: .green,
            category: .education
        ),
        Challenge(
            id: "meal-prep",
            title: "Prepare meals for tomorrow",
            icon: "takeoutbag.and.cup.and.straw.fill",
            color: .cyan,
            category: .planning
        ),
        Challenge(
            id: "try-protein",
            title: "Try a new plant protein source",
            icon: "leaf.fill",
            color: .green,
            category: .cooking
        ),
        Challenge(
            id: "share-recipe",
            title: "Share your favorite recipe with a friend",
            icon: "heart.text.square.fill",
            color: .pink,
            category: .social
        ),
        Challenge(
            id: "watch-documentary",
            title: "Watch a vegan documentary",
            icon: "play.rectangle.fill",
            color: .red,
            category: .education
        ),
        Challenge(
            id: "farmers-market",
            title: "Visit a farmers market",
            icon: "basket.fill",
            color: .orange,
            category: .exploration
        ),
        Challenge(
            id: "smoothie",
            title: "Make a nutritious green smoothie",
            icon: "cup.and.saucer.fill",
            color: .green,
            category: .cooking
        ),
        Challenge(
            id: "read-labels",
            title: "Learn to read ingredient labels",
            icon: "text.magnifyingglass",
            color: .indigo,
            category: .education
        ),
        Challenge(
            id: "batch-cook",
            title: "Batch cook for the week",
            icon: "refrigerator.fill",
            color: .cyan,
            category: .planning
        )
    ]
}

// MARK: - Challenge Model

struct Challenge: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let category: Category
    var isCompleted: Bool = false
    
    enum Category {
        case cooking
        case exploration
        case social
        case education
        case planning
        
        var name: String {
            switch self {
            case .cooking: return "Cooking"
            case .exploration: return "Exploration"
            case .social: return "Social"
            case .education: return "Education"
            case .planning: return "Planning"
            }
        }
    }
}

// MARK: - Seeded Random Number Generator

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        state = seed
    }
    
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
