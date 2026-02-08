# Referral System & Monetization Implementation Guide

## 🎉 What's Been Implemented

### 1. Premium Subscription System (StoreKit 2)
- **Files Created:**
  - `SubscriptionManager.swift` - Handles all StoreKit operations
  - `PaywallView.swift` - Beautiful premium upgrade screen
  - `PremiumBadge.swift` - Reusable premium badge component
  - `Products.storekit` - StoreKit configuration file

**Features:**
- ✅ Monthly subscription ($2.99/month)
- ✅ Yearly subscription ($19.99/year with 44% savings)
- ✅ 1-week free trial for both tiers
- ✅ Auto-renewable subscriptions
- ✅ Purchase restoration
- ✅ Transaction verification
- ✅ Automatic subscription status updates

**Premium Benefits:**
- Unlimited streak freezes
- All share templates
- Advanced stats & charts
- Widget themes
- Custom app icons
- Remove branding from shares
- Early access to features
- Priority support

---

### 2. Referral System with Rewards
- **Files Created:**
  - `ReferralManager.swift` - Complete referral logic
  - `ReferralView.swift` - Referral dashboard UI
  - `StreakFreezeView.swift` - Streak freeze management
  - `SettingsView.swift` - App settings with premium/referral integration

**Features:**
- ✅ Unique 6-character referral codes
- ✅ Automatic reward tracking
- ✅ Streak freeze currency system
- ✅ Milestone-based rewards
- ✅ Beautiful referral dashboard
- ✅ One-tap sharing
- ✅ Progress tracking

**Referral Rewards:**
- **New User Bonus:** 1 streak freeze when joining with a code
- **1 Referral:** 2 streak freezes
- **3 Referrals:** 3 streak freezes + Exclusive badge
- **5 Referrals:** 7 days of Premium
- **10 Referrals:** 30 days of Premium
- **25 Referrals:** 1 YEAR of Premium! 🎉

---

### 3. Streak Freeze System
- **Updated:** `StreakManager.swift` with freeze logic
- **Created:** `StreakFreezeView.swift` for freeze management

**Features:**
- ✅ Auto-protect streaks when missed by 1 day
- ✅ Free users earn freezes via referrals
- ✅ Premium users get unlimited freezes
- ✅ Automatic freeze application
- ✅ Freeze usage tracking
- ✅ Notifications when freeze is used

---

### 4. Enhanced Settings
- **Created:** `SettingsView.swift`

**Features:**
- ✅ Premium status display
- ✅ Subscription management
- ✅ Referral code quick copy
- ✅ Notification settings
- ✅ Account management
- ✅ About & legal links

---

## 🚀 How to Complete the Integration

### Step 1: Add to Your Main App File

Update your `GoingVeganApp.swift`:

```swift
import SwiftUI

@main
struct GoingVeganApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var referralManager = ReferralManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
                .environmentObject(referralManager)
        }
    }
}
```

### Step 2: Update Your HomeScreenView

Add these properties to your `HomeScreenView`:

```swift
@StateObject private var subscriptionManager = SubscriptionManager()
@StateObject private var referralManager = ReferralManager()
@State private var showSettings = false
@State private var showPaywall = false
@State private var showReferrals = false
```

Add toolbar buttons:

```swift
.toolbar {
    ToolbarItem(placement: .topBarLeading) {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
        }
    }
    
    ToolbarItem(placement: .topBarTrailing) {
        if !subscriptionManager.isPremium {
            Button {
                showPaywall = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                    Text("Premium")
                }
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
        }
    }
}
.sheet(isPresented: $showSettings) {
    SettingsView(
        subscriptionManager: subscriptionManager,
        referralManager: referralManager
    )
}
.sheet(isPresented: $showPaywall) {
    PaywallView(subscriptionManager: subscriptionManager)
}
```

### Step 3: Add Referral Button to Your UI

Add this somewhere prominent (maybe near your stats):

```swift
Button {
    showReferrals = true
} label: {
    HStack {
        Image(systemName: "person.3.fill")
        VStack(alignment: .leading, spacing: 2) {
            Text("Invite Friends")
                .font(.subheadline.weight(.semibold))
            Text("Earn rewards")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        
        Spacer()
        
        if referralManager.availableStreakFreezes > 0 {
            HStack(spacing: 4) {
                Image(systemName: "snowflake")
                Text("\(referralManager.availableStreakFreezes)")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(.blue))
        }
        
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.secondarySystemBackground))
    )
}
.buttonStyle(.plain)
.sheet(isPresented: $showReferrals) {
    ReferralView(referralManager: referralManager)
}
```

### Step 4: Update Streak Calculation

When you calculate streaks, pass the managers:

```swift
streakManager.calculateStreak(
    from: anyDays,
    referralManager: referralManager,
    subscriptionManager: subscriptionManager
)
```

### Step 5: Handle New User Referrals

In your onboarding or first-time user flow, add:

```swift
// Check if user came from a referral link
if let referralCode = UserDefaults.standard.string(forKey: "pendingReferralCode") {
    referralManager.setReferredBy(code: referralCode)
    UserDefaults.standard.removeObject(forKey: "pendingReferralCode")
}

// After user completes their first day:
if referralManager.referredByCode != nil {
    referralManager.activateReferral { success in
        if success {
            // Show "You earned 1 streak freeze!" message
        }
    }
}
```

### Step 6: App Store Connect Configuration

#### A. Create In-App Purchases

1. Go to App Store Connect
2. Select your app
3. Go to "Features" → "In-App Purchases"
4. Create two auto-renewable subscriptions:
   - **Product ID:** `com.goingvegan.premium.monthly`
   - **Product ID:** `com.goingvegan.premium.yearly`

5. Set up subscription group: "Premium"
6. Configure pricing:
   - Monthly: $2.99 USD
   - Yearly: $19.99 USD (save 44%)

7. Add free trial: 1 week for both

8. Add localizations and descriptions

#### B. Add StoreKit Configuration

1. In Xcode, add `Products.storekit` to your project
2. Edit scheme → Options → StoreKit Configuration
3. Select `Products.storekit`
4. Now you can test purchases without real transactions!

### Step 7: Deep Linking for Referrals

Add to your `Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>goingvegan</string>
        </array>
    </dict>
</array>
```

Handle deep links in your app:

```swift
.onOpenURL { url in
    // Handle goingvegan://referral?code=ABC123
    if url.scheme == "goingvegan",
       url.host == "referral",
       let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
       let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
        
        // Store for after user signs up
        UserDefaults.standard.set(code, forKey: "pendingReferralCode")
    }
}
```

### Step 8: Testing

#### Test Subscriptions:
1. Use StoreKit configuration file for local testing
2. Create sandbox tester accounts in App Store Connect
3. Test purchase flow, restoration, and auto-renewal

#### Test Referrals:
```swift
// In debug builds, add a test button:
#if DEBUG
Button("Test Referral") {
    referralManager.addSuccessfulReferral(userName: "Test User")
}
#endif
```

---

## 📱 Premium Features Implementation

### Feature Gating

Check premium status before showing features:

```swift
if subscriptionManager.hasAccess(to: .unlimitedStreakFreezes) {
    // Show unlimited freezes UI
} else {
    // Show limited freezes with upgrade prompt
}
```

### Custom Share Templates (Premium)

```swift
func generateShareImage(template: ShareTemplate) -> UIImage? {
    // Check premium
    guard subscriptionManager.isPremium || template == .basic else {
        // Show paywall
        return nil
    }
    
    // Generate image with selected template
}
```

### Advanced Stats (Premium)

```swift
if subscriptionManager.isPremium {
    NavigationLink("Detailed Analytics") {
        AdvancedStatsView()
    }
} else {
    Button("Unlock Advanced Stats") {
        showPaywall = true
    }
}
```

---

## 🎯 Viral Growth Mechanics

### 1. Onboarding Flow with Referral
- Ask for referral code during sign-up
- Show "You'll earn a bonus!" message
- Activate reward after first check-in

### 2. Post-Milestone Sharing
After celebrations, prompt to invite friends:

```swift
// In MilestoneCelebrationView
Button("Invite Friends to Join") {
    showReferralView = true
}
```

### 3. Streak Risk Alerts
When streak is at risk:

```swift
if streakManager.isStreakAtRisk() {
    if referralManager.availableStreakFreezes == 0 && !subscriptionManager.isPremium {
        // Show: "Invite 1 friend to get streak freezes!"
    }
}
```

### 4. Social Proof
Show community stats:

```swift
// In a prominent location
Text("Join 50,000+ vegans tracking their journey")
    .font(.caption)
    .foregroundStyle(.secondary)
```

---

## 🔐 Privacy & Security

### Referral Codes
- Generated client-side
- No PII in codes
- Can be rotated if needed

### Subscription Status
- Verified using StoreKit 2's built-in verification
- Transactions are cryptographically signed by Apple
- No server validation needed (though recommended for production)

### User Data
- All data stored locally in UserDefaults
- No analytics by default (add TelemetryDeck if needed)
- GDPR compliant

---

## 💡 Marketing Copy Suggestions

### App Store Description

**Title:** GoingVegan - Plant-Based Tracker

**Subtitle:** Track Your Vegan Journey & Impact

**Description:**
```
Join thousands making a difference! 🌱

GoingVegan helps you track your plant-based journey with:

🔥 STREAK TRACKING
Build momentum with daily check-ins and never lose progress with streak freezes

🏆 ACHIEVEMENTS
Unlock 13+ achievements as you reach milestones

💪 DAILY CHALLENGES
Stay engaged with fresh daily goals

📊 IMPACT METRICS
See exactly how many animals, CO₂, water, and land you've saved

👥 INVITE FRIENDS
Share your journey and earn rewards together

✨ PREMIUM FEATURES
• Unlimited streak freezes
• Advanced analytics
• Custom widgets
• Exclusive app icons
• Remove branding
• Priority support

Start your journey today! 🌍
```

### Social Media

**Instagram/TikTok Bio:**
```
Track your vegan journey 🌱
Save animals | Earn rewards | Make an impact
👇 Download now
```

**Launch Post:**
```
Excited to launch GoingVegan! 🎉

We built this because staying vegan shouldn't be hard. Now you can:
✅ Track your progress
✅ See your real impact
✅ Earn rewards for inviting friends
✅ Never lose your streak

Join 1,000+ early adopters! Link in bio 👆

#vegan #plantbased #veganapp #sustainability
```

---

## 📈 Success Metrics to Track

### Week 1
- [ ] 100 downloads
- [ ] 40% Day 1 retention
- [ ] 5 premium conversions
- [ ] 10 referrals generated

### Month 1
- [ ] 1,000 users
- [ ] 20% Day 30 retention
- [ ] $500 MRR
- [ ] K-factor > 0.5

### Month 3
- [ ] 10,000 users
- [ ] 50 premium subscribers
- [ ] $2,000 MRR
- [ ] Featured by Apple 🤞

---

## 🐛 Common Issues & Solutions

### Issue: "Cannot connect to App Store"
**Solution:** Make sure StoreKit configuration is selected in scheme

### Issue: Products not loading
**Solution:** Check product IDs match exactly in code and StoreKit file

### Issue: Referral code not working
**Solution:** Ensure deep linking is set up in Info.plist and URL scheme handler

### Issue: Streak freeze not applying
**Solution:** Verify managers are passed to `calculateStreak()`

---

## 🎓 Next Steps

1. **Test everything locally** using StoreKit Configuration
2. **Create App Store Connect** listings for subscriptions
3. **Set up TestFlight** for beta testing
4. **Add analytics** (recommend TelemetryDeck - privacy-focused)
5. **Create marketing materials** using templates
6. **Soft launch** to get initial feedback
7. **Submit to App Store** 🚀

---

## 💰 Revenue Projections

**Conservative Estimate (1,000 users after 3 months):**
- 5% conversion to premium = 50 subscribers
- 70% choose yearly ($19.99) = 35 × $19.99 = $699
- 30% choose monthly ($2.99) = 15 × $2.99 = $45/month × 12 = $540
- **Total Year 1 Revenue: ~$1,239**

**Moderate Estimate (10,000 users after 6 months):**
- 8% conversion = 800 subscribers
- **Total Year 1 Revenue: ~$15,000**

**Optimistic Estimate (100,000 users after 1 year):**
- 10% conversion = 10,000 subscribers
- **Total Year 1 Revenue: ~$150,000** 💰

---

## 🙏 Credits

Built with:
- SwiftUI
- StoreKit 2
- UserNotifications
- Foundation

No external dependencies! 🎉

---

## 📞 Support

For questions or issues with this implementation, check:
1. This README
2. Inline code comments
3. Apple's StoreKit documentation

**Happy launching! Let's make veganism go viral! 🚀🌱**
