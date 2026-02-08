//
//  ReferralView.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import SwiftUI

struct ReferralView: View {
    @ObservedObject var referralManager: ReferralManager
    @State private var showShareSheet = false
    @State private var showRewardDetail: ReferralReward?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text("Invite Friends")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("Share GoingVegan and earn amazing rewards together")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 32)
                    
                    // Referral Code Card
                    VStack(spacing: 16) {
                        Text("Your Referral Code")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(referralManager.referralCode)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .tracking(4)
                        
                        Button {
                            UIPasteboard.general.string = referralManager.referralCode
                            
                            // Haptic feedback
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        } label: {
                            Label("Copy Code", systemImage: "doc.on.doc")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.purple, .blue],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal, 20)
                    
                    // Stats
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Referrals",
                            value: "\(referralManager.referralCount)",
                            icon: "person.2.fill",
                            color: .purple
                        )
                        
                        StatCard(
                            title: "Streak Freezes",
                            value: "\(referralManager.availableStreakFreezes)",
                            icon: "snowflake",
                            color: .blue
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Share Button
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share with Friends", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.purple, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                    .padding(.horizontal, 20)
                    
                    // How It Works
                    VStack(alignment: .leading, spacing: 20) {
                        Text("How It Works")
                            .font(.title2.bold())
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            HowItWorksStep(
                                number: "1",
                                title: "Share Your Code",
                                description: "Send your unique referral code to friends"
                            )
                            
                            HowItWorksStep(
                                number: "2",
                                title: "They Join & Complete Day 1",
                                description: "Friend downloads app and completes their first vegan day"
                            )
                            
                            HowItWorksStep(
                                number: "3",
                                title: "You Both Get Rewards",
                                description: "Unlock streak freezes, premium trials, and exclusive badges"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical)
                    
                    // Rewards Milestones
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Referral Rewards")
                            .font(.title2.bold())
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            RewardMilestone(
                                referrals: 1,
                                reward: "2 Streak Freezes",
                                icon: "snowflake",
                                isUnlocked: referralManager.referralCount >= 1
                            )
                            
                            RewardMilestone(
                                referrals: 3,
                                reward: "3 Streak Freezes + Badge",
                                icon: "star.fill",
                                isUnlocked: referralManager.referralCount >= 3
                            )
                            
                            RewardMilestone(
                                referrals: 5,
                                reward: "7 Days Premium",
                                icon: "crown.fill",
                                isUnlocked: referralManager.referralCount >= 5
                            )
                            
                            RewardMilestone(
                                referrals: 10,
                                reward: "30 Days Premium",
                                icon: "megaphone.fill",
                                isUnlocked: referralManager.referralCount >= 10
                            )
                            
                            RewardMilestone(
                                referrals: 25,
                                reward: "1 YEAR Premium!",
                                icon: "trophy.fill",
                                isUnlocked: referralManager.referralCount >= 25
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical)
                    
                    // Successful Referrals List
                    if !referralManager.successfulReferrals.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Referrals")
                                .font(.title2.bold())
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(referralManager.successfulReferrals) { referral in
                                    ReferralRow(referral: referral)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical)
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Referrals")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showShareSheet) {
                if let url = referralManager.getReferralLink() {
                    ShareSheet(items: [referralManager.getReferralMessage(), url])
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct HowItWorksStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Text(number)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct RewardMilestone: View {
    let referrals: Int
    let reward: String
    let icon: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isUnlocked ? .green : .gray)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(referrals) Referral\(referrals == 1 ? "" : "s")")
                    .font(.headline)
                    .foregroundStyle(isUnlocked ? .primary : .secondary)
                
                Text(reward)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .opacity(isUnlocked ? 1.0 : 0.6)
        )
    }
}

struct ReferralRow: View {
    let referral: Referral
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(referral.userName)
                    .font(.headline)
                
                Text("Joined \(referral.dateJoined, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if referral.status == .completed {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ReferralView(referralManager: ReferralManager())
}
