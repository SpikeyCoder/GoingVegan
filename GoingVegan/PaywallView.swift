//
//  PaywallView.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Go Premium")
                            .font(.system(size: 36, weight: .bold))
                        
                        Text("Unlock all features and maximize your vegan journey")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 32)
                    
                    // Features List
                    VStack(spacing: 16) {
                        FeatureRow(
                            icon: "snowflake",
                            title: "Unlimited Streak Freezes",
                            description: "Never lose your streak again"
                        )
                        
                        FeatureRow(
                            icon: "photo.stack",
                            title: "All Share Templates",
                            description: "Beautiful designs for every milestone"
                        )
                        
                        FeatureRow(
                            icon: "chart.xyaxis.line",
                            title: "Advanced Stats & Charts",
                            description: "Deep insights into your journey"
                        )
                        
                        FeatureRow(
                            icon: "paintbrush",
                            title: "Widget Themes",
                            description: "Customize your home screen widgets"
                        )
                        
                        FeatureRow(
                            icon: "app.badge",
                            title: "Custom App Icons",
                            description: "Personalize your app icon"
                        )
                        
                        FeatureRow(
                            icon: "sparkles",
                            title: "Remove Branding",
                            description: "Clean shares without watermarks"
                        )
                        
                        FeatureRow(
                            icon: "clock.badge.checkmark",
                            title: "Early Access",
                            description: "Be first to try new features"
                        )
                        
                        FeatureRow(
                            icon: "headphones",
                            title: "Priority Support",
                            description: "Get help when you need it"
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Subscription Options
                    VStack(spacing: 12) {
                        ForEach(subscriptionManager.availableSubscriptions, id: \.id) { product in
                            SubscriptionOptionCard(
                                product: product,
                                isSelected: selectedProduct?.id == product.id,
                                savings: product.id.contains("yearly") ? subscriptionManager.yearlySavings() : nil
                            )
                            .onTapGesture {
                                selectedProduct = product
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Subscribe Button
                    Button {
                        guard let product = selectedProduct else { return }
                        Task {
                            await subscriptionManager.purchase(product)
                            if case .purchased = subscriptionManager.purchaseState {
                                dismiss()
                            }
                        }
                    } label: {
                        Group {
                            if case .loading = subscriptionManager.purchaseState {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(selectedProduct != nil ? "Start Premium" : "Select a Plan")
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Capsule()
                                .fill(
                                    selectedProduct != nil ?
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [.gray, .gray],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .disabled(selectedProduct == nil || subscriptionManager.purchaseState == .loading)
                    .padding(.horizontal, 20)
                    
                    // Restore Purchases
                    Button {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Terms and Privacy
                    HStack(spacing: 16) {
                        Link("Terms", destination: URL(string: "https://yourwebsite.com/terms")!)
                        Text("•")
                        Link("Privacy", destination: URL(string: "https://yourwebsite.com/privacy")!)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .alert("Success", isPresented: .constant(subscriptionManager.purchaseState == .restored)) {
                Button("OK") {
                    subscriptionManager.purchaseState = .idle
                    if subscriptionManager.isPremium {
                        dismiss()
                    }
                }
            } message: {
                Text(subscriptionManager.isPremium ? "Your purchases have been restored!" : "No purchases found to restore.")
            }
            .alert("Error", isPresented: .constant({
                if case .failed = subscriptionManager.purchaseState {
                    return true
                }
                return false
            }())) {
                Button("OK") {
                    subscriptionManager.purchaseState = .idle
                }
            } message: {
                if case .failed(let error) = subscriptionManager.purchaseState {
                    Text(error.localizedDescription)
                } else {
                    Text("An error occurred")
                }
            }
        }
        .onAppear {
            // Pre-select yearly if available
            if let yearly = subscriptionManager.availableSubscriptions.first(where: { $0.id.contains("yearly") }) {
                selectedProduct = yearly
            } else {
                selectedProduct = subscriptionManager.availableSubscriptions.first
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Subscription Option Card

struct SubscriptionOptionCard: View {
    let product: Product
    let isSelected: Bool
    let savings: String?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(product.displayName)
                        .font(.headline)
                    
                    if let savings = savings {
                        Text("Save \(savings)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.green)
                            )
                    }
                }
                
                Text(product.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(product.displayPrice)
                    .font(.title3.bold())
                
                if product.id.contains("yearly") {
                    Text("per year")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("per month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            isSelected ? Color.green : Color.clear,
                            lineWidth: 3
                        )
                )
        )
    }
}

#Preview {
    PaywallView(subscriptionManager: SubscriptionManager())
}
