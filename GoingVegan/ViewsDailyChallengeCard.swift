//
//  DailyChallengeCard.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import SwiftUI

struct DailyChallengeCard: View {
    let challenge: Challenge
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(challenge.color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: challenge.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(challenge.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Challenge")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(challenge.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            // Complete button
            Button(action: {
                onComplete()
            }) {
                Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundStyle(challenge.isCompleted ? .green : .gray.opacity(0.3))
                    .contentTransition(.symbolEffect(.replace))
            }
            .disabled(challenge.isCompleted)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(challenge.color.opacity(challenge.isCompleted ? 0.3 : 0.1), lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today's challenge: \(challenge.title). \(challenge.isCompleted ? "Completed" : "Not completed")")
        .accessibilityAddTraits(challenge.isCompleted ? [] : .isButton)
    }
}

// Preview removed due to duplicate DailyChallengeCard definition
// This file duplicates DailyChallengeCard.swift and should likely be removed
