//
//  CelebrationView.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import SwiftUI

struct MilestoneCelebrationView: View {
    let milestone: Milestone
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Confetti overlay
            if isAnimating {
                MilestoneConfettiView(color: milestone.color)
            }
            
            // Card
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
                
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(milestone.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: milestone.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(milestone.color)
                }
                .scaleEffect(scale)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: scale)
                
                // Title
                Text(milestone.title)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                
                // Message
                Text(milestone.message)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                Spacer()
                
                // Share button
                ShareLink(
                    item: generateShareText(),
                    subject: Text("My Vegan Journey"),
                    message: Text(milestone.message)
                ) {
                    Label("Share Achievement", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(milestone.color)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Continue button
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
            )
            .padding(40)
            .opacity(opacity)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
                isAnimating = true
            }
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    private func generateShareText() -> String {
        switch milestone {
        case .firstDay:
            return "🌱 Just completed my first vegan day with GoingVegan!"
        case .week:
            return "💪 7 days strong on my vegan journey!"
        case .twoWeeks:
            return "⚡️ 14 days of making a difference!"
        case .month:
            return "🌟 30 days of plant-based living! Feeling amazing!"
        case .fiftyDays:
            return "✨ 50 days of positive impact on my vegan journey!"
        case .hundred:
            return "🎉 100 vegan days! Making a real difference for animals and the planet!"
        case .sixMonths:
            return "👑 6 months of compassionate living!"
        case .year:
            return "🏆 One full year of compassionate living! 365 days vegan!"
        }
    }
}

// MARK: - Confetti View (Private Extension)

private struct MilestoneConfettiView: View {
    let color: Color
    @State private var confettiPieces: [MilestoneConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces, id: \.id) { piece in
                    MilestoneConfettiShape()
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
            let piece = MilestoneConfettiPiece(
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
    
    private func animateConfetti(piece: MilestoneConfettiPiece, in size: CGSize) {
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

private struct MilestoneConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    var position: CGPoint
    let size: CGFloat
    var rotation: Angle
    var opacity: Double
}

private struct MilestoneConfettiShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        return path
    }
}

#Preview {
    MilestoneCelebrationView(milestone: .month)
}
