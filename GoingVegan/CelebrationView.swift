//
//  CelebrationView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/8/26.
//

import SwiftUI

struct CelebrationView: View {
    let milestone: Milestone
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var showConfetti = false
    @State private var iconBounce: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 24) {
                // Icon with animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [milestone.color.opacity(0.3), milestone.color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: milestone.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(milestone.color)
                        .scaleEffect(iconBounce)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                VStack(spacing: 12) {
                    Text(milestone.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(milestone.message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .opacity(opacity)
                
                // Share button
                Button {
                    // TODO: Share achievement
                    dismiss()
                } label: {
                    Label("Share Achievement", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [milestone.color, milestone.color.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .padding(.horizontal, 32)
                .opacity(opacity)
                
                // Close button
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .opacity(opacity)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .strokeBorder(milestone.color.opacity(0.3), lineWidth: 2)
            )
            .padding(32)
            .scaleEffect(scale)
            
            // Confetti overlay
            if showConfetti {
                ConfettiView(color: milestone.color)
            }
        }
        .onAppear {
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Animate appearance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Animate icon bounce
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).repeatForever(autoreverses: true)) {
                iconBounce = 1.2
            }
            
            // Show confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
            }
        }
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    let color: Color
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces, id: \.id) { piece in
                    ConfettiShape()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size)
                        .rotationEffect(piece.rotation)
                        .position(piece.position)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func generateConfetti(in size: CGSize) {
        let colors: [Color] = [color, color.opacity(0.7), .yellow, .orange, .pink, .purple]
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                color: colors.randomElement() ?? color,
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: -20),
                size: CGFloat.random(in: 8...15),
                rotation: Angle(degrees: Double.random(in: 0...360)),
                opacity: 1.0
            )
            confettiPieces.append(piece)
            
            animateConfetti(piece: piece, in: size)
        }
    }
    
    private func animateConfetti(piece: ConfettiPiece, in size: CGSize) {
        if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
            let endY = size.height + 20
            let endX = piece.position.x + CGFloat.random(in: -100...100)
            
            withAnimation(.easeOut(duration: Double.random(in: 2...4))) {
                confettiPieces[index].position = CGPoint(x: endX, y: endY)
                confettiPieces[index].rotation = Angle(degrees: Double.random(in: 360...720))
                confettiPieces[index].opacity = 0
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    var position: CGPoint
    let size: CGFloat
    var rotation: Angle
    var opacity: Double
}

struct ConfettiShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        return path
    }
}

#Preview {
    CelebrationView(milestone: .month)
}
