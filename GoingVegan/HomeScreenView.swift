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
    var viewModel: AuthenticationViewModel
    @State var loadDatesIsComplete: Bool = false
    @State private var showingTransition = true
    @State private var uniqueDateCount: Int = 0
    
    init(viewModel:AuthenticationViewModel) {
        self.viewModel = viewModel
        self.load()
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
                    
                    // Impact Metrics Cards - Improved Design
                    ImpactMetricsSection(dateCount: uniqueDateCount)
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
                                    self.updateUniqueDateCount()
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
        }
        .sheet(isPresented: $showingTransition) {
            TransitionView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    func load() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
               if self.viewModel.isPopulated {
                    guard let sess = self.viewModel.session else {return}
                    guard let days = sess.veganDays else {return}
                    print("HERE LIES THE TOTAL COUNT TO CHECK AGAINST: \(days.count-1)")
                    self.anyDays = days
                    self.updateUniqueDateCount()
                    loadDatesIsComplete = true
                    showingTransition = false
                }
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

struct ImpactMetricsSection: View {
    let dateCount: Int
    
    private var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }
    
    private func formattedNumber(_ value: Double, decimals: Int = 0) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Impact")
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(dateCount) day\(dateCount == 1 ? "" : "s")")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Your Impact: \(dateCount) vegan day\(dateCount == 1 ? "" : "s")")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ImpactMetricCard(
                    icon: "leaf.fill",
                    title: "Animals Saved",
                    value: formattedNumber(Double(dateCount)),
                    color: .green,
                    unit: "animal\(dateCount == 1 ? "" : "s")"
                )
                
                ImpactMetricCard(
                    icon: "cloud.fill",
                    title: "CO₂ Saved",
                    value: formattedNumber(Double(dateCount) * 6.4, decimals: 1),
                    color: .blue,
                    unit: "lbs"
                )
                
                ImpactMetricCard(
                    icon: "drop.fill",
                    title: "Water Saved",
                    value: formattedNumber(Double(dateCount) * 1100),
                    color: .cyan,
                    unit: "gallons"
                )
                
                ImpactMetricCard(
                    icon: "tree.fill",
                    title: "Land Saved",
                    value: formattedNumber(Double(dateCount) * 30),
                    color: .orange,
                    unit: "sq ft"
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
        .accessibilityElement(children: .contain)
    }
}

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

// MARK: - Preview

struct HomeScreenView_Previews: PreviewProvider {
        static var previews: some View {
            HomeScreenView(viewModel: AuthenticationViewModel())
        }
    }
