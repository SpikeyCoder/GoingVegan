//
//  SettingsView.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @ObservedObject var referralManager: ReferralManager
    @State private var showPaywall = false
    @State private var showReferralView = false
    @State private var notificationsEnabled = true
    
    var body: some View {
        NavigationStack {
            List {
                // Premium Section
                Section {
                    if subscriptionManager.isPremium {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Premium Active")
                                        .font(.headline)
                                    PremiumBadge(size: .small)
                                }
                                
                                if let subscription = subscriptionManager.currentSubscription {
                                    Text(subscription.displayName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                        }
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Upgrade to Premium")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    
                                    Text("Unlock all features")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Subscription")
                }
                
                // Referral Section
                Section {
                    Button {
                        showReferralView = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Invite Friends")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("\(referralManager.referralCount) successful referrals")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if referralManager.availableStreakFreezes > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "snowflake")
                                        .font(.caption)
                                    Text("\(referralManager.availableStreakFreezes)")
                                        .font(.caption.weight(.semibold))
                                }
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(.blue.opacity(0.1))
                                )
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Your Code")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(referralManager.referralCode)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.primary)
                        
                        Button {
                            UIPasteboard.general.string = referralManager.referralCode
                            
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Referrals")
                } footer: {
                    Text("Share your code and earn rewards when friends join")
                }
                
                // Notifications
                Section {
                    Toggle("Daily Reminders", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            if newValue {
                                NotificationManager.shared.requestAuthorization { _ in }
                            }
                        }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get reminded to maintain your streak")
                }
                
                // About
                Section {
                    Link(destination: URL(string: "https://yourwebsite.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Link(destination: URL(string: "https://yourwebsite.com/terms")!) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("About")
                }
                
                // Account
                Section {
                    if subscriptionManager.isPremium {
                        Button("Manage Subscription") {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                        Button("Restore Purchases") {
                            Task {
                                await subscriptionManager.restorePurchases()
                            }
                        }
                    }
                    
                    Button("Sign Out") {
                        // Handle sign out
                    }
                    .foregroundStyle(.red)
                } header: {
                    Text("Account")
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView(subscriptionManager: subscriptionManager)
            }
            .sheet(isPresented: $showReferralView) {
                ReferralView(referralManager: referralManager)
            }
        }
    }
}

#Preview {
    SettingsView(
        subscriptionManager: SubscriptionManager(),
        referralManager: ReferralManager()
    )
}
