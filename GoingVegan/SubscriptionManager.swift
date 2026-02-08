//
//  SubscriptionManager.swift
//  GoingVegan
//
//  Created by AI Assistant on 2/8/26.
//

import Foundation
import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var currentSubscription: Product?
    @Published var availableSubscriptions: [Product] = []
    @Published var purchaseState: PurchaseState = .idle
    
    private var updateListenerTask: Task<Void, Error>?
    
    // Product IDs - Configure these in App Store Connect
    private let productIds = [
        "com.goingvegan.premium.monthly",
        "com.goingvegan.premium.yearly"
    ]
    
    enum PurchaseState {
        case idle
        case loading
        case purchased
        case failed(Error)
        case restored
    }
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        do {
            let products = try await Product.products(for: productIds)
            self.availableSubscriptions = products.sorted { product1, product2 in
                // Sort yearly before monthly
                product1.id.contains("yearly") && product2.id.contains("monthly")
            }
        } catch {
            print("Failed to load products: \(error)")
            self.availableSubscriptions = []
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async {
        purchaseState = .loading
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updatePurchasedProducts()
                purchaseState = .purchased
                
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
            case .userCancelled:
                purchaseState = .idle
                
            case .pending:
                purchaseState = .idle
                
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            print("Purchase failed: \(error)")
            purchaseState = .failed(error)
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        purchaseState = .loading
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            purchaseState = .restored
        } catch {
            print("Restore failed: \(error)")
            purchaseState = .failed(error)
        }
    }
    
    // MARK: - Transaction Verification
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Update Purchased Products
    
    func updatePurchasedProducts() async {
        var purchasedSubscriptions: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if let subscription = availableSubscriptions.first(where: { $0.id == transaction.productID }) {
                    purchasedSubscriptions.append(subscription)
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        self.currentSubscription = purchasedSubscriptions.first
        self.isPremium = !purchasedSubscriptions.isEmpty
        
        // Save premium status to UserDefaults for quick access
        UserDefaults.standard.set(isPremium, forKey: "isPremium")
    }
    
    // MARK: - Transaction Listener
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    await transaction.finish()
                    await updatePurchasedProducts()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Feature Access
    
    func hasAccess(to feature: PremiumFeature) -> Bool {
        return isPremium || feature.isFreeTier
    }
    
    // MARK: - Pricing
    
    func monthlyPrice() -> String {
        guard let monthly = availableSubscriptions.first(where: { $0.id.contains("monthly") }) else {
            return "$2.99"
        }
        return monthly.displayPrice
    }
    
    func yearlyPrice() -> String {
        guard let yearly = availableSubscriptions.first(where: { $0.id.contains("yearly") }) else {
            return "$19.99"
        }
        return yearly.displayPrice
    }
    
    func yearlySavings() -> String {
        guard let monthly = availableSubscriptions.first(where: { $0.id.contains("monthly") }),
              let yearly = availableSubscriptions.first(where: { $0.id.contains("yearly") }) else {
            return "33%"
        }
        
        // Calculate savings
        let monthlyAnnualCost = (monthly.price * 12) as NSDecimalNumber
        let yearlyCost = yearly.price as NSDecimalNumber
        let savings = monthlyAnnualCost.subtracting(yearlyCost)
        let percentage = (savings.doubleValue / monthlyAnnualCost.doubleValue) * 100
        
        return String(format: "%.0f%%", percentage)
    }
}

// MARK: - Extensions

extension SubscriptionManager.PurchaseState: Equatable {
    static func == (lhs: SubscriptionManager.PurchaseState, rhs: SubscriptionManager.PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.purchased, .purchased),
             (.restored, .restored):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// MARK: - Store Error

enum StoreError: Error {
    case failedVerification
}

// MARK: - Premium Features

enum PremiumFeature {
    case unlimitedStreakFreezes
    case allShareTemplates
    case advancedStats
    case widgetThemes
    case customAppIcons
    case prioritySupport
    case noBranding
    case earlyAccess
    
    var isFreeTier: Bool {
        // Basic features that are always free
        return false
    }
    
    var title: String {
        switch self {
        case .unlimitedStreakFreezes: return "Unlimited Streak Freezes"
        case .allShareTemplates: return "All Share Templates"
        case .advancedStats: return "Advanced Stats & Charts"
        case .widgetThemes: return "Widget Themes"
        case .customAppIcons: return "Custom App Icons"
        case .prioritySupport: return "Priority Support"
        case .noBranding: return "Remove Branding"
        case .earlyAccess: return "Early Access to Features"
        }
    }
    
    var icon: String {
        switch self {
        case .unlimitedStreakFreezes: return "snowflake"
        case .allShareTemplates: return "photo.stack"
        case .advancedStats: return "chart.xyaxis.line"
        case .widgetThemes: return "paintbrush"
        case .customAppIcons: return "app.badge"
        case .prioritySupport: return "headphones"
        case .noBranding: return "sparkles"
        case .earlyAccess: return "clock.badge.checkmark"
        }
    }
}
