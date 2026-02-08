//
//  AchievementsView.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var achievementManager: AchievementManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 12)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(achievementManager.unlockedCount) / CGFloat(achievementManager.totalCount))
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                            
                            VStack(spacing: 4) {
                                Text("\(achievementManager.unlockedCount)")
                                    .font(.system(size: 36, weight: .bold))
                                Text("/ \(achievementManager.totalCount)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text("Achievements Unlocked")
                            .font(.headline)
                    }
                    .padding(.top)
                    
                    // Achievement grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(achievementManager.achievements) { achievement in
                            AchievementBadge(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    @State private var showDetail = false
    
    var body: some View {
        Button {
            if achievement.isUnlocked {
                showDetail = true
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? achievement.color.color.opacity(0.15) : Color(.systemGray6))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 28))
                        .foregroundStyle(achievement.isUnlocked ? achievement.color.color : .gray)
                    
                    if !achievement.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .offset(x: 20, y: 20)
                    }
                }
                
                Text(achievement.name)
                    .font(.caption.weight(achievement.isUnlocked ? .semibold : .regular))
                    .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        achievement.isUnlocked ? achievement.color.color.opacity(0.3) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(achievement.name). \(achievement.description). \(achievement.isUnlocked ? "Unlocked" : "Locked")")
        .sheet(isPresented: $showDetail) {
            AchievementDetailView(achievement: achievement)
                .presentationDetents([.medium])
        }
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Close button
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.color.color.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 40))
                    .foregroundStyle(achievement.color.color)
            }
            
            // Name
            Text(achievement.name)
                .font(.title.bold())
            
            // Description
            Text(achievement.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Unlock date
            if let unlockedDate = achievement.unlockedDate {
                VStack(spacing: 4) {
                    Text("Unlocked on")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(unlockedDate, style: .date)
                        .font(.subheadline.weight(.medium))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            
            Spacer()
            
            // Share button
            if achievement.isUnlocked {
                ShareLink(
                    item: "🏆 Just unlocked '\(achievement.name)' in GoingVegan! \(achievement.description)",
                    subject: Text("Achievement Unlocked!"),
                    message: Text(achievement.description)
                ) {
                    Label("Share Achievement", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(achievement.color.color)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    AchievementsView(achievementManager: AchievementManager())
}
