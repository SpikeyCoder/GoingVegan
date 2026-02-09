//
//  ReferralManager.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import Foundation
import SwiftUI

class ReferralManager: ObservableObject {
    @Published var referralCode: String = ""
    @Published var referredByCode: String?
    @Published var referralCount: Int = 0
    @Published var successfulReferrals: [Referral] = []
    @Published var earnedRewards: [ReferralReward] = []
    @Published var availableStreakFreezes: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let referralCodeKey = "userReferralCode"
    private let referredByKey = "referredByCode"
    private let referralCountKey = "referralCount"
    private let successfulReferralsKey = "successfulReferrals"
    private let earnedRewardsKey = "earnedRewards"
    private let streakFreezesKey = "availableStreakFreezes"
    private let referralAPI: ReferralAPI
    
    init(api: ReferralAPI = DefaultReferralAPI()) {
        self.referralAPI = api
        loadReferralData()
        if referralCode.isEmpty {
            generateReferralCode()
        }
    }
    
    // MARK: - Generate Referral Code
    
    private func generateReferralCode() {
        // Generate a unique 6-character code
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        let code = String((0..<6).map { _ in characters.randomElement()! })
        
        referralCode = code
        saveReferralData()
    }
    
    // MARK: - Set Referred By
    
    func setReferredBy(code: String) {
        guard referredByCode == nil else {
            print("Already referred by someone")
            return
        }
        
        referredByCode = code
        saveReferralData()
        
        // Send notification to backend that this user was referred
        // For now, we'll just track locally
        print("User was referred by: \(code)")
    }
    
    // MARK: - Complete First Day (Activate Referral)
    
    func activateReferral(completion: @escaping (Bool) -> Void) {
        guard let referrerCode = referredByCode else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let isValid = try await referralAPI.verifyReferrer(code: referrerCode)
                guard isValid else {
                    await MainActor.run { completion(false) }
                    return
                }
                
                try await referralAPI.awardReferrer(forCode: referrerCode)
                try await referralAPI.trackSuccessfulReferral(referrerCode: referrerCode, refereeReferralCode: self.referralCode)
                
                await MainActor.run {
                    self.earnReward(.newUserBonus)
                    completion(true)
                }
            } catch {
                print("Referral activation failed: \(error)")
                await MainActor.run {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Track Successful Referral
    
    func addSuccessfulReferral(userName: String) {
        let referral = Referral(
            userName: userName,
            dateJoined: Date(),
            isActive: true,
            status: .completed
        )
        
        successfulReferrals.append(referral)
        referralCount += 1
        
        // Award rewards based on milestones
        checkAndAwardMilestoneRewards()
        
        saveReferralData()
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Rewards
    
    private func checkAndAwardMilestoneRewards() {
        // Award rewards at specific milestones
        if referralCount == 1 {
            earnReward(.firstReferral)
        } else if referralCount == 3 {
            earnReward(.threeReferrals)
        } else if referralCount == 5 {
            earnReward(.fiveReferrals)
        } else if referralCount == 10 {
            earnReward(.tenReferrals)
        } else if referralCount == 25 {
            earnReward(.twentyFiveReferrals)
        }
    }
    
    private func earnReward(_ reward: ReferralReward) {
        guard !earnedRewards.contains(where: { $0.id == reward.id }) else {
            return
        }
        
        earnedRewards.append(reward)
        
        // Apply reward benefits
        switch reward.type {
        case .streakFreeze(let count):
            availableStreakFreezes += count
        case .premiumTrial(let days):
            // This would trigger premium access for X days
            print("Earned \(days) days of premium trial")
        case .exclusiveBadge:
            // Unlock special badge
            print("Earned exclusive badge: \(reward.title)")
        }
        
        saveReferralData()
        
        // Show notification
        NotificationManager.shared.sendReferralRewardNotification(reward: reward)
    }
    
    // MARK: - Use Streak Freeze
    
    func useStreakFreeze() -> Bool {
        guard availableStreakFreezes > 0 else {
            return false
        }
        
        availableStreakFreezes -= 1
        saveReferralData()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        return true
    }
    
    // MARK: - Referral Link
    
    func getReferralLink() -> URL? {
        // In production, this would be your app's deep link
        // Format: goingvegan://referral?code=ABC123
        // or universal link: https://goingvegan.app/ref/ABC123
        
        guard let encoded = referralCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: "https://goingvegan.app/ref/\(encoded)")
    }
    
    func getReferralMessage() -> String {
        return """
        🌱 Join me on GoingVegan!
        
        I'm tracking my plant-based journey and making a real impact. Use my code \(referralCode) to get a bonus streak freeze when you join!
        
        Download: https://goingvegan.app/ref/\(referralCode)
        """
    }
    
    // MARK: - Persistence
    
    private func saveReferralData() {
        userDefaults.set(referralCode, forKey: referralCodeKey)
        userDefaults.set(referredByCode, forKey: referredByKey)
        userDefaults.set(referralCount, forKey: referralCountKey)
        userDefaults.set(availableStreakFreezes, forKey: streakFreezesKey)
        
        // Save referrals
        if let encoded = try? JSONEncoder().encode(successfulReferrals) {
            userDefaults.set(encoded, forKey: successfulReferralsKey)
        }
        
        // Save rewards
        if let encoded = try? JSONEncoder().encode(earnedRewards) {
            userDefaults.set(encoded, forKey: earnedRewardsKey)
        }
    }
    
    private func loadReferralData() {
        referralCode = userDefaults.string(forKey: referralCodeKey) ?? ""
        referredByCode = userDefaults.string(forKey: referredByKey)
        referralCount = userDefaults.integer(forKey: referralCountKey)
        availableStreakFreezes = userDefaults.integer(forKey: streakFreezesKey)
        
        // Load referrals
        if let data = userDefaults.data(forKey: successfulReferralsKey),
           let decoded = try? JSONDecoder().decode([Referral].self, from: data) {
            successfulReferrals = decoded
        }
        
        // Load rewards
        if let data = userDefaults.data(forKey: earnedRewardsKey),
           let decoded = try? JSONDecoder().decode([ReferralReward].self, from: data) {
            earnedRewards = decoded
        }
    }
    
    // MARK: - Clear Data (for testing)
    
    func clearReferralData() {
        referralCode = ""
        referredByCode = nil
        referralCount = 0
        successfulReferrals = []
        earnedRewards = []
        availableStreakFreezes = 0
        
        userDefaults.removeObject(forKey: referralCodeKey)
        userDefaults.removeObject(forKey: referredByKey)
        userDefaults.removeObject(forKey: referralCountKey)
        userDefaults.removeObject(forKey: successfulReferralsKey)
        userDefaults.removeObject(forKey: earnedRewardsKey)
        userDefaults.removeObject(forKey: streakFreezesKey)
        
        generateReferralCode()
    }
}

// MARK: - Models

struct Referral: Identifiable, Codable {
    let id = UUID()
    let userName: String
    let dateJoined: Date
    let isActive: Bool
    let status: ReferralStatus
    
    enum CodingKeys: String, CodingKey {
        case id, userName, dateJoined, isActive, status
    }
}

enum ReferralStatus: String, Codable {
    case pending      // Signed up but hasn't completed first day
    case completed    // Completed first day (reward unlocked)
    case inactive     // No longer active
}

struct ReferralReward: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let type: RewardType
    let dateEarned: Date
    
    enum RewardType: Codable, Equatable {
        case streakFreeze(count: Int)
        case premiumTrial(days: Int)
        case exclusiveBadge
        
        enum CodingKeys: String, CodingKey {
            case type, count, days
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "streakFreeze":
                let count = try container.decode(Int.self, forKey: .count)
                self = .streakFreeze(count: count)
            case "premiumTrial":
                let days = try container.decode(Int.self, forKey: .days)
                self = .premiumTrial(days: days)
            case "exclusiveBadge":
                self = .exclusiveBadge
            default:
                self = .exclusiveBadge
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .streakFreeze(let count):
                try container.encode("streakFreeze", forKey: .type)
                try container.encode(count, forKey: .count)
            case .premiumTrial(let days):
                try container.encode("premiumTrial", forKey: .type)
                try container.encode(days, forKey: .days)
            case .exclusiveBadge:
                try container.encode("exclusiveBadge", forKey: .type)
            }
        }
    }
    
    // Predefined rewards
    static let newUserBonus = ReferralReward(
        id: "new_user_bonus",
        title: "Welcome Bonus!",
        description: "You earned 1 streak freeze for joining with a referral code",
        icon: "gift.fill",
        type: .streakFreeze(count: 1),
        dateEarned: Date()
    )
    
    static let firstReferral = ReferralReward(
        id: "first_referral",
        title: "First Referral!",
        description: "You earned 2 streak freezes for your first successful referral",
        icon: "person.fill.badge.plus",
        type: .streakFreeze(count: 2),
        dateEarned: Date()
    )
    
    static let threeReferrals = ReferralReward(
        id: "three_referrals",
        title: "Influencer",
        description: "3 referrals! Earned exclusive badge and 3 streak freezes",
        icon: "star.fill",
        type: .streakFreeze(count: 3),
        dateEarned: Date()
    )
    
    static let fiveReferrals = ReferralReward(
        id: "five_referrals",
        title: "Community Builder",
        description: "5 referrals! Earned 7 days of Premium",
        icon: "crown.fill",
        type: .premiumTrial(days: 7),
        dateEarned: Date()
    )
    
    static let tenReferrals = ReferralReward(
        id: "ten_referrals",
        title: "Ambassador",
        description: "10 referrals! Earned 30 days of Premium",
        icon: "megaphone.fill",
        type: .premiumTrial(days: 30),
        dateEarned: Date()
    )
    
    static let twentyFiveReferrals = ReferralReward(
        id: "twenty_five_referrals",
        title: "Legend",
        description: "25 referrals! Earned 1 YEAR of Premium!",
        icon: "trophy.fill",
        type: .premiumTrial(days: 365),
        dateEarned: Date()
    )
}

