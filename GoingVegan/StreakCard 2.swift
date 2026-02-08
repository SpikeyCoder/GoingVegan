//
//  StreakCard.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/8/26.
//

import SwiftUI

struct StreakCard: View {
    let currentStreak: Int
    let longestStreak: Int
    let isAtRisk: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Streak")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        if #available(iOS 17.0, *) {
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundStyle(streakColor)
                                .symbolEffect(.bounce, value: currentStreak)
                        } else {
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundStyle(streakColor)
                        }
                        
                        Text("\(currentStreak)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())
                        
                        Text(currentStreak == 1 ? "day" : "days")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Longest")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                        
                        Text("\(longestStreak)")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                    }
                }
            }
            
            // At Risk Warning
            if isAtRisk {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    
                    Text("Check in today to keep your streak alive!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            streakGradientColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [streakColor.opacity(0.3), streakColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: streakColor.opacity(0.2), radius: 10, x: 0, y: 5)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current streak: \(currentStreak) \(currentStreak == 1 ? "day" : "days"). Longest streak: \(longestStreak) \(longestStreak == 1 ? "day" : "days")")
    }
    
    private var streakColor: Color {
        if currentStreak == 0 {
            return .gray
        } else if currentStreak < 7 {
            return .orange
        } else if currentStreak < 30 {
            return .red
        } else if currentStreak < 100 {
            return .purple
        } else {
            return .blue
        }
    }
    
    private var streakGradientColor: Color {
        streakColor.opacity(0.05)
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakCard(currentStreak: 0, longestStreak: 5, isAtRisk: false)
        StreakCard(currentStreak: 5, longestStreak: 10, isAtRisk: false)
        StreakCard(currentStreak: 30, longestStreak: 30, isAtRisk: false)
        StreakCard(currentStreak: 15, longestStreak: 20, isAtRisk: true)
    }
    .padding()
}
