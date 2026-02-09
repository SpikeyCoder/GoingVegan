//
//  HomeScreenView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/13/23.
//

import SwiftUI

class CounterModel: NSObject {
    var count = 0
}

struct HomeScreenView: View {
    @State private var anyDays = [Date]()
    var counterModel = CounterModel()
    var dateFormatter = DateFormatter()
    @ObservedObject var viewModel: AuthenticationViewModel
    @State var loadDatesIsComplete: Bool = false
    @State private var showingTransition = true
    @State private var uniqueDateCount: Int = 0
    
    // New viral features
    @StateObject private var streakManager = StreakManager()
    @StateObject private var achievementManager = AchievementManager()
    @StateObject private var challengeManager = ChallengeManager()
    
    @State private var showCelebration = false
    @State private var celebrationMilestone: Milestone?
    @State private var showAchievements = false
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    
    init(viewModel:AuthenticationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vegan Journey")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text("Track your progress and see your positive impact on the world")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Streak Card
                    StreakCard(
                        currentStreak: streakManager.currentStreak,
                        longestStreak: streakManager.longestStreak,
                        isAtRisk: streakManager.isStreakAtRisk()
                    )
                    .padding(.horizontal, 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: streakManager.currentStreak)
                    
                    // Daily Challenge
                    if let challenge = challengeManager.todaysChallenge {
                        DailyChallengeCard(challenge: challenge) {
                            challengeManager.completeChallenge()
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Impact Metrics Cards with Share Button
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Impact")
                                    .font(.title3.bold())
                                    .foregroundStyle(.primary)
                                
                                Text("\(uniqueDateCount) day\(uniqueDateCount == 1 ? "" : "s")")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            // Share button
                            Button {
                                shareImpact()
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [.green, .blue],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                            }
                            .accessibilityLabel("Share your impact")
                        }
                        .padding(.horizontal, 20)
                        
                        // Impact metrics grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ImpactMetricCard(
                                icon: "leaf.fill",
                                title: "Animals Saved",
                                value: formattedNumber(Double(uniqueDateCount)),
                                color: .green,
                                unit: "animal\(uniqueDateCount == 1 ? "" : "s")"
                            )
                            
                            ImpactMetricCard(
                                icon: "cloud.fill",
                                title: "CO₂ Saved",
                                value: formattedNumber(Double(uniqueDateCount) * 6.4, decimals: 1),
                                color: .blue,
                                unit: "lbs"
                            )
                            
                            ImpactMetricCard(
                                icon: "drop.fill",
                                title: "Water Saved",
                                value: formattedNumber(Double(uniqueDateCount) * 1100),
                                color: .cyan,
                                unit: "gallons"
                            )
                            
                            ImpactMetricCard(
                                icon: "tree.fill",
                                title: "Land Saved",
                                value: formattedNumber(Double(uniqueDateCount) * 30),
                                color: .orange,
                                unit: "sq ft"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Achievements Preview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Achievements")
                                .font(.title3.bold())
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button {
                                showAchievements = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("\(achievementManager.unlockedCount)/\(achievementManager.totalCount)")
                                        .font(.subheadline.weight(.semibold))
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(achievementManager.achievements.prefix(6)) { achievement in
                                    CompactAchievementBadge(achievement: achievement)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Calendar Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Check-In Your Vegan Days")
                            .font(.title3.bold())
                            .foregroundStyle(.primary)
                            .accessibilityAddTraits(.isHeader)
                        
                        if loadDatesIsComplete {
                            MultiDatePicker(
                                anyDays: $anyDays, 
                                includeDays: .allDays,
                                maxDate: Date()
                            )
                                .onChange(of: anyDays) { newValue in
                                    self.viewModel.saveDays(days: newValue)
                                    self.updateMetrics()
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                )
                                .accessibilityElement(children: .contain)
                                .accessibilityLabel("Vegan days calendar")
                        } else {
                            ProgressView("Loading your progress...")
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            // Profile or settings
                        } label: {
                            Label("Profile", systemImage: "person.circle")
                        }
                        
                        Button {
                            showAchievements = true
                        } label: {
                            Label("Achievements", systemImage: "trophy")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            viewModel.signOut()
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            // Show confirmation alert before deleting
                            viewModel.deleteUser()
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .accessibilityLabel("More options")
                    }
                }
            }
        }
        .onAppear {
            self.load()
            // Fallback timeout to avoid indefinite loading overlay
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if showingTransition {
                    showingTransition = false
                }
            }
        }
        .onChange(of: viewModel.isPopulated) { populated in
            if populated {
                if let sess = viewModel.session, let days = sess.veganDays {
                    self.anyDays = days
                    self.updateMetrics()
                    loadDatesIsComplete = true
                }
                showingTransition = false
            }
        }
        .overlay {
            if showingTransition {
                TransitionView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .sheet(isPresented: $showAchievements) {
            AchievementsView(achievementManager: achievementManager)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image, "Check out my vegan impact! 🌱"])
            }
        }
    }
    
    func load() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
               if self.viewModel.isPopulated {
                    guard let sess = self.viewModel.session else {return}
                    guard let days = sess.veganDays else {return}
                    print("HERE LIES THE TOTAL COUNT TO CHECK AGAINST: \(days.count-1)")
                    self.anyDays = days
                    self.updateMetrics()
                    loadDatesIsComplete = true
                    showingTransition = false
                }
            }
      }
    
    func updateMetrics() {
        updateUniqueDateCount()
        
        // Update streak asynchronously
        Task {
            await streakManager.calculateStreak(from: anyDays)
            
            // Check for milestone on main actor
            await MainActor.run {
                if let milestone = streakManager.checkForMilestone() {
                    celebrationMilestone = milestone
                    
                    // Small delay to ensure UI is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showCelebration = true
                    }
                }
            }
        }
        
        // Check for achievements
        let newAchievements = achievementManager.checkAchievements(
            daysCount: uniqueDateCount,
            currentStreak: streakManager.currentStreak,
            recipesCooked: 0, // TODO: Track this
            restaurantsVisited: 0, // TODO: Track this
            friendsInvited: 0, // TODO: Track this
            challengesCompleted: challengeManager.completedCount
        )
        
        // Show achievement notifications (could be improved with custom UI)
        for achievement in newAchievements {
            print("🏆 Achievement unlocked: \(achievement.name)")
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    func updateUniqueDateCount() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        
        let dateStrings = anyDays.map { formatter.string(from: $0) }
        let uniqueDateStrings = Set(dateStrings)
        uniqueDateCount = uniqueDateStrings.count
        viewModel.dateCount = uniqueDateCount
    }
    
    func shareImpact() {
        let image = ShareManager.generateImpactImage(
            days: uniqueDateCount,
            animals: uniqueDateCount,
            co2: Double(uniqueDateCount) * 6.4,
            water: Double(uniqueDateCount) * 1100,
            land: Double(uniqueDateCount) * 30
        )
        
        shareImage = image
        showShareSheet = true
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func formattedNumber(_ value: Double, decimals: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
    
    func calculatedAnimalSavingsText(_ days: [Date]) -> some View {
        calculateUniqueDateCount(days: days)
       if(self.viewModel.dateCount == Int(1)){
           return Text("\(self.viewModel.dateCount)").padding().shadow(radius: 10.0, x: 20, y: 10).background(
            Circle()
              .stroke(.gray, lineWidth: 4)
              .frame(width: 50, height: 50)
       )}
        return Text("\(self.viewModel.dateCount)").padding().shadow(radius: 10.0, x: 20, y: 10).background(
              Circle()
                .stroke(.gray, lineWidth: 4)
                .frame(width: 50, height: 50)
   )}
   
    func calculatedCO2SavingsText(_ days: [Date]) -> some View {
        calculateUniqueDateCount(days: days)
        return Text("\(String(format:"%.1f",Double(self.viewModel.dateCount) * 6.4))").padding().background(
            Circle()
              .stroke(.gray, lineWidth: 4)
              .frame(width: 50, height: 50)
    )}
    
    func calculateUniqueDateCount(days:[Date]) {
        self.dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let savedDatesString = days.map {dateFormatter.string(from: $0)}
        let uniqueDatesString = Array(Set(savedDatesString))
        let savedDatesCount = uniqueDatesString.count
        self.viewModel.dateCount = savedDatesCount
    }
    
    
    // MARK: - Supporting Views - No longer needed (commented for reference)
    // Old helper views removed in favor of card-based design
}

// MARK: - New Impact Metrics Components

struct ImpactMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let unit: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(color)
                .accessibilityHidden(true)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(.primary)
            
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 140)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.tertiarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.2), lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value) \(unit)")
    }
}

// MARK: - Supporting Views

struct CompactAchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color.color.opacity(0.15) : Color(.systemGray6))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(achievement.isUnlocked ? achievement.color.color : .gray)
                
                if !achievement.isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.gray)
                        .offset(x: 15, y: 15)
                }
            }
            
            Text(achievement.name)
                .font(.caption2)
                .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                .lineLimit(1)
        }
        .frame(width: 70)
    }
}

// MARK: - Preview

struct HomeScreenView_Previews: PreviewProvider {
        static var previews: some View {
            HomeScreenView(viewModel: AuthenticationViewModel())
        }
    }
