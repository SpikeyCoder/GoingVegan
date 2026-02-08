//
//  PremiumBadge.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import SwiftUI

struct PremiumBadge: View {
    var size: BadgeSize = .medium
    
    enum BadgeSize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: size.iconSize))
            
            Text("PREMIUM")
                .font(size.fontSize.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, size.padding + 4)
        .padding(.vertical, size.padding)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        PremiumBadge(size: .small)
        PremiumBadge(size: .medium)
        PremiumBadge(size: .large)
    }
    .padding()
}
