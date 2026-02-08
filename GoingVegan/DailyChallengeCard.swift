//
//  DailyChallengeCard.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/8/26.
//

import SwiftUI

struct DailyChallengeCard: View {
    let challenge: Challenge
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(challenge.color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: challenge.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(challenge.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Challenge")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Text(challenge.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Complete button
            Button(action: onComplete) {
                ZStack {
                    Circle()
                        .fill(challenge.isCompleted ? Color.green.opacity(0.15) : Color(.systemGray6))
                        .frame(width: 40, height: 40)
                    
                    if #available(iOS 17.0, *) {
                        Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundStyle(challenge.isCompleted ? .green : .secondary)
                            .symbolEffect(.bounce, value: challenge.isCompleted)
                    } else {
                        Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundStyle(challenge.isCompleted ? .green : .secondary)
                    }
                }
            }
            .disabled(challenge.isCompleted)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    challenge.isCompleted ? Color.green.opacity(0.3) : Color.clear,
                    lineWidth: 2
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today's Challenge: \(challenge.title). \(challenge.isCompleted ? "Completed" : "Not completed")")
        .accessibilityHint(challenge.isCompleted ? "" : "Double tap to mark as complete")
    }
}

#Preview {
    VStack(spacing: 16) {
        DailyChallengeCard(
            challenge: Challenge(
                id: "preview1",
                title: "Try a new vegan recipe",
                icon: "frying.pan.fill",
                color: .orange,
                category: .cooking,
                isCompleted: false
            ),
            onComplete: {}
        )
        
        DailyChallengeCard(
            challenge: Challenge(
                id: "preview2",
                title: "Share a photo of your vegan meal",
                icon: "camera.fill",
                color: .purple,
                category: .social,
                isCompleted: true
            ),
            onComplete: {}
        )
    }
    .padding()
}
