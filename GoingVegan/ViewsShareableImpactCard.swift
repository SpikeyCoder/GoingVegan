//
//  ShareableImpactCard.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import SwiftUI

struct ShareableImpactCard: View {
    let days: Int
    let animals: Int
    let co2: Double
    let water: Double
    let land: Double
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("My Vegan Impact")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("\(days) Day\(days == 1 ? "" : "s")")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            
            // Metrics
            VStack(spacing: 16) {
                ImpactRow(icon: "leaf.fill", value: "\(animals)", unit: "animal\(animals == 1 ? "" : "s") saved", color: .green)
                ImpactRow(icon: "cloud.fill", value: String(format: "%.1f", co2), unit: "lbs CO₂ reduced", color: .blue)
                ImpactRow(icon: "drop.fill", value: String(format: "%.0f", water), unit: "gallons water saved", color: .cyan)
                ImpactRow(icon: "tree.fill", value: String(format: "%.0f", land), unit: "sq ft land preserved", color: .orange)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.15))
            )
            
            // Footer
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.white)
                Text("GoingVegan")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding()
            .background(
                Capsule()
                    .fill(.white.opacity(0.2))
            )
        }
        .padding(40)
        .frame(width: 400, height: 600)
        .background(
            LinearGradient(
                colors: [.green, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct ImpactRow: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(unit)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

@MainActor
class ShareManager {
    static func generateImpactImage(days: Int, animals: Int, co2: Double, water: Double, land: Double) -> UIImage {
        let view = ShareableImpactCard(
            days: days,
            animals: animals,
            co2: co2,
            water: water,
            land: land
        )
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0 // High resolution
        
        return renderer.uiImage ?? UIImage()
    }
}

#Preview {
    ShareableImpactCard(
        days: 157,
        animals: 157,
        co2: 1004.8,
        water: 172700,
        land: 4710
    )
}
