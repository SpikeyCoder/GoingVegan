//
//  StreakFreezeView.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import SwiftUI

struct StreakFreezeView: View {
    @ObservedObject var referralManager: ReferralManager
    @ObservedObject var subscriptionManager: SubscriptionManager
    @ObservedObject var streakManager: StreakManager
    @Environment(\.dismiss) private var dismiss
    @State private var showPremiumPaywall = false
    
    var canUseFreeze: Bool {
        return referralManager.availableStreakFreezes > 0 || subscriptionManager.isPremium
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .cyan.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "snowflake")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text("Streak Freeze")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("Protect your streak when life gets in the way")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 32)
                    
                    // Current Streak
                    VStack(spacing: 12) {
                        Text("Current Streak")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.title)
                                .foregroundStyle(.orange)
                            
                            Text("\(streakManager.currentStreak)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.orange)
                            
                            Text("days")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal, 20)
                    
                    // Available Freezes
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Available Freezes")
                                    .font(.headline)
                                
                                if subscriptionManager.isPremium {
                                    HStack(spacing: 6) {
                                        Image(systemName: "crown.fill")
                                            .foregroundStyle(.yellow)
                                        Text("Unlimited")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.yellow)
                                    }
                                } else {
                                    Text("\(referralManager.availableStreakFreezes)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundStyle(.blue)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "snowflake")
                                .font(.system(size: 40))
                                .foregroundStyle(.blue.opacity(0.3))
                        }
                        
                        if !subscriptionManager.isPremium {
                            Text("Earn more by inviting friends or upgrade to Premium for unlimited freezes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal, 20)
                    
                    // How It Works
                    VStack(alignment: .leading, spacing: 20) {
                        Text("How It Works")
                            .font(.title2.bold())
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            InfoCard(
                                icon: "calendar.badge.exclamationmark",
                                title: "Miss a Day",
                                description: "Life happens - you miss checking in"
                            )
                            
                            InfoCard(
                                icon: "snowflake",
                                title: "Auto Protection",
                                description: "A freeze is used automatically to save your streak"
                            )
                            
                            InfoCard(
                                icon: "flame.fill",
                                title: "Keep Going",
                                description: "Your streak continues as if nothing happened"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Get More Freezes
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Get More Freezes")
                            .font(.title2.bold())
                            .padding(.horizontal, 20)
                        
                        if !subscriptionManager.isPremium {
                            // Premium Option
                            Button {
                                showPremiumPaywall = true
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "crown.fill")
                                                .foregroundStyle(.yellow)
                                            Text("Go Premium")
                                                .font(.headline)
                                        }
                                        
                                        Text("Unlimited freezes + all premium features")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [.yellow.opacity(0.2), .orange.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .strokeBorder(.yellow.opacity(0.5), lineWidth: 2)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }
                        
                        // Referral Option
                        NavigationLink(destination: ReferralView(referralManager: referralManager)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "person.3.fill")
                                            .foregroundStyle(.purple)
                                        Text("Invite Friends")
                                            .font(.headline)
                                    }
                                    
                                    Text("Earn 2+ freezes per successful referral")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Streak Freeze")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPremiumPaywall) {
                PaywallView(subscriptionManager: subscriptionManager)
            }
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)
            
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

#Preview {
    StreakFreezeView(
        referralManager: ReferralManager(),
        subscriptionManager: SubscriptionManager(),
        streakManager: StreakManager()
    )
}
