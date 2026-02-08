//
//  AchievementManager.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/8/26.
//

import Foundation
import SwiftUI

class AchievementManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        achievements.count
    }
    
    init() {
        setupAchievements()
        loadProgress()
    }
    
    private func setupAchievements() {
        achievements = [
            // Streak Achievements
            Achievement(
                id: "seedling",
                name: "Seedling",
                description: "Complete your first vegan day",
                icon: "leaf.fill",
                color: .green,
                requirement: .days(1)
            ),
            Achievement(
                id: "fireStarter",
                name: "Fire Starter",
                description: "Maintain a 7-day streak",
                icon: "flame.fill",
                color: .orange,
                requirement: .streak(7)
            ),
            Achievement(
                id: "committed",
                name: "Committed",
                description: "Complete 30 vegan days",
                icon: "heart.fill",
                color: .red,
                requirement: .days(30)
            ),
            Achievement(
                id: "centuryClub",
                name: "Century Club",
                description: "Reach 100 vegan days",
                icon: "trophy.fill",
                color: .blue,
                requirement: .days(100)
            ),
            Achievement(
                id: "hero",
                name: "Hero",
                description: "Complete 365 vegan days",
                icon: "star.fill",
                color: .yellow,
                requirement: .days(365)
            ),
            
            // Recipe Achievements
            Achievement(
                id: "chef",
                name: "Chef",
                description: "Cook 10 vegan recipes",
                icon: "frying.pan.fill",
                color: .orange,
                requirement: .recipes(10)
            ),
            Achievement(
                id: "masterChef",
                name: "Master Chef",
                description: "Cook 50 vegan recipes",
                icon: "chef.hat.fill",
                color: .purple,
                requirement: .recipes(50)
            ),
            
            // Restaurant Achievements
            Achievement(
                id: "explorer",
                name: "Explorer",
                description: "Visit 5 vegan restaurants",
                icon: "map.fill",
                color: .cyan,
                requirement: .restaurants(5)
            ),
            Achievement(
                id: "foodie",
                name: "Foodie",
                description: "Visit 25 vegan restaurants",
                icon: "fork.knife",
                color: .indigo,
                requirement: .restaurants(25)
            ),
            
            // Social Achievements
            Achievement(
                id: "influencer",
                name: "Influencer",
                description: "Invite 3 friends to join",
                icon: "person.3.fill",
                color: .pink,
                requirement: .friends(3)
            ),
            Achievement(
                id: "ambassador",
                name: "Ambassador",
                description: "Invite 10 friends to join",
                icon: "megaphone.fill",
                color: .green,
                requirement: .friends(10)
            ),
            
            // Challenge Achievements
            Achievement(
                id: "challenger",
                name: "Challenger",
                description: "Complete 10 daily challenges",
                icon: "checkmark.seal.fill",
                color: .blue,
                requirement: .challenges(10)
            ),
            Achievement(
                id: "dedicated",
                name: "Dedicated",
                description: "Complete 50 daily challenges",
                icon: "trophy.fill",
                color: .orange,
                requirement: .challenges(50)
            )
        ]
    }
    
    func checkAchievements(
        daysCount: Int,
        currentStreak: Int,
        recipesCooked: Int,
        restaurantsVisited: Int,
        friendsInvited: Int,
        challengesCompleted: Int
    ) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        
        for index in achievements.indices {
            if !achievements[index].isUnlocked {
                let shouldUnlock: Bool
                
                switch achievements[index].requirement {
                case .days(let required):
                    shouldUnlock = daysCount >= required
                case .streak(let required):
                    shouldUnlock = currentStreak >= required
                case .recipes(let required):
                    shouldUnlock = recipesCooked >= required
                case .restaurants(let required):
                    shouldUnlock = restaurantsVisited >= required
                case .friends(let required):
                    shouldUnlock = friendsInvited >= required
                case .challenges(let required):
                    shouldUnlock = challengesCompleted >= required
                }
                
                if shouldUnlock {
                    achievements[index].isUnlocked = true
                    achievements[index].unlockedDate = Date()
                    newlyUnlocked.append(achievements[index])
                }
            }
        }
        
        if !newlyUnlocked.isEmpty {
            saveProgress()
        }
        
        return newlyUnlocked
    }
    
    private func saveProgress() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: "achievements")
        }
    }
    
    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: "achievements"),
              let decoded = try? JSONDecoder().decode([Achievement].self, from: data) else {
            return
        }
        
        // Merge with current achievements (in case we added new ones)
        for saved in decoded {
            if let index = achievements.firstIndex(where: { $0.id == saved.id }) {
                achievements[index].isUnlocked = saved.isUnlocked
                achievements[index].unlockedDate = saved.unlockedDate
            }
        }
    }
}

// MARK: - Achievement Model

struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: AchievementColor
    let requirement: Requirement
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    
    enum Requirement: Codable {
        case days(Int)
        case streak(Int)
        case recipes(Int)
        case restaurants(Int)
        case friends(Int)
        case challenges(Int)
        
        var displayText: String {
            switch self {
            case .days(let count): return "\(count) vegan days"
            case .streak(let count): return "\(count)-day streak"
            case .recipes(let count): return "\(count) recipes"
            case .restaurants(let count): return "\(count) restaurants"
            case .friends(let count): return "\(count) friends"
            case .challenges(let count): return "\(count) challenges"
            }
        }
    }
    
    enum AchievementColor: String, Codable {
        case green, blue, red, orange, yellow, purple, pink, cyan, indigo
        
        var color: Color {
            switch self {
            case .green: return .green
            case .blue: return .blue
            case .red: return .red
            case .orange: return .orange
            case .yellow: return .yellow
            case .purple: return .purple
            case .pink: return .pink
            case .cyan: return .cyan
            case .indigo: return .indigo
            }
        }
    }
}
