//
//  TransitionView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/8/26.
//

import SwiftUI

struct TransitionView: View {
    @State private var isAnimating = false
    @State private var rotation = 0.0
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animated leaf icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.3), .green.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 0.5 : 1)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(rotation))
                }
                
                // Loading text
                Text("Loading Your Journey...")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .opacity(isAnimating ? 1 : 0.6)
                
                // Progress indicator
                ProgressView()
                    .tint(.green)
                    .scaleEffect(1.2)
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    TransitionView()
}
