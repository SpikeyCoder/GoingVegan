//
//  RecipeListView.swift
//  test
//
//  Created by Kevin Armstrong on 1/13/23.
//

import SwiftUI
import CoreData
import MapKit
import Foundation
import EventKit

struct RecipeListView: View {
    @State private var recipes: [Recipe] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingGroceryList = false
    
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading recipes...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if let error = errorMessage {
                    emptyStateView(
                        title: "Unable to Load Recipes",
                        systemImage: "exclamationmark.triangle",
                        description: error
                    )
                } else if recipes.isEmpty {
                    emptyStateView(
                        title: "No Recipes Yet",
                        systemImage: "fork.knife",
                        description: "Check back soon for delicious vegan recipes!"
                    )
                } else {
                    recipeListContent
                }
            }
            .navigationTitle("Vegan Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingGroceryList = true }) {
                        Label("Grocery List", systemImage: "cart")
                    }
                    .disabled(viewModel.groceryListString.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { 
                        Task {
                            await loadRecipes()
                        }
                    }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .sheet(isPresented: $showingGroceryList) {
                NavigationView {
                    groceryListScreen()
                        .environmentObject(viewModel)
                }
            }
        }
        .task {
            await loadRecipes()
        }
    }
    
    @ViewBuilder
    private func emptyStateView(title: String, systemImage: String, description: String) -> some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView(
                title,
                systemImage: systemImage,
                description: Text(description)
            )
        } else {
            VStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var recipeListContent: some View {
        List {
            ForEach(recipes, id: \.self) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRowView(recipe: recipe)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await loadRecipes()
        }
    }
    
    private func loadRecipes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedRecipes = try await fetchRecipesFromAPI()
            await MainActor.run {
                self.recipes = fetchedRecipes
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load recipes. Please try again."
                self.isLoading = false
            }
        }
    }
    
    private func fetchRecipesFromAPI() async throws -> [Recipe] {
        let url = URL(string: "https://x8rdk85zn2.execute-api.us-east-1.amazonaws.com/prod/recipes")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.timeoutInterval = 10.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode([Recipe].self, from: data)
    }
}

// MARK: - Recipe Model
struct Recipe: Codable, Hashable {
    var recipe_name: String
    var recipe_author: String
    var shopping_list: [String]
    var recipe_instructions: String
    var recipe_image: String
}

// MARK: - Grocery List Screen
struct groceryListScreen: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var checkedItems: Set<String> = []
    
    // Get individual grocery items as an array
    private var groceryItems: [String] {
        viewModel.groceryListString
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
    
    // Format for sharing with checkbox symbols
    private var formattedGroceryList: String {
        groceryItems
            .map { "☐ \($0)" }
            .joined(separator: "\n")
    }
    
    var body: some View {
        Group {
            if groceryItems.isEmpty {
                emptyGroceryListView
            } else {
                groceryListContent
            }
        }
        .navigationTitle("Grocery List")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: addToReminders) {
                        Label("Add to Reminders", systemImage: "checklist")
                    }
                    
                    ShareLink(
                        item: formattedGroceryList,
                        subject: Text("Grocery List"),
                        message: Text("My Vegan Grocery List")
                    ) {
                        Label("Share List", systemImage: "square.and.arrow.up")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: clearList) {
                        Label("Clear List", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .alert("Reminders", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    @ViewBuilder
    private var emptyGroceryListView: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView(
                "No Items Yet",
                systemImage: "cart",
                description: Text("Add ingredients from recipes to build your grocery list")
            )
        } else {
            VStack(spacing: 16) {
                Image(systemName: "cart")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text("No Items Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add ingredients from recipes to build your grocery list")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var groceryListContent: some View {
        VStack(spacing: 0) {
            // Progress indicator
            if !checkedItems.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(checkedItems.count) of \(groceryItems.count) items checked")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
            }
            
            List {
                ForEach(groceryItems, id: \.self) { item in
                    GroceryItemRow(
                        item: item,
                        isChecked: checkedItems.contains(item),
                        onToggle: {
                            toggleItem(item)
                        }
                    )
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(.insetGrouped)
        }
    }
    
    private func toggleItem(_ item: String) {
        withAnimation {
            if checkedItems.contains(item) {
                checkedItems.remove(item)
            } else {
                checkedItems.insert(item)
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        var items = groceryItems
        items.remove(atOffsets: offsets)
        viewModel.groceryListString = items.joined(separator: "\n")
    }
    
    private func clearList() {
        withAnimation {
            viewModel.groceryListString = ""
            checkedItems.removeAll()
        }
    }
    
    private func addToReminders() {
        let eventStore = EKEventStore()
        
        // Request access to reminders
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToReminders { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        createReminders(in: eventStore)
                    } else {
                        alertMessage = "Please enable Reminders access in Settings to add grocery items."
                        showingAlert = true
                    }
                }
            }
        } else {
            eventStore.requestAccess(to: .reminder) { granted, error in
                DispatchQueue.main.async {
                    if granted {
                        createReminders(in: eventStore)
                    } else {
                        alertMessage = "Please enable Reminders access in Settings to add grocery items."
                        showingAlert = true
                    }
                }
            }
        }
    }
    
    private func createReminders(in eventStore: EKEventStore) {
        guard let defaultCalendar = eventStore.defaultCalendarForNewReminders() else {
            alertMessage = "Could not access default reminders list."
            showingAlert = true
            return
        }
        
        var successCount = 0
        
        // Create a reminder for each grocery item
        for item in groceryItems where !checkedItems.contains(item) {
            let reminder = EKReminder(eventStore: eventStore)
            reminder.title = item
            reminder.calendar = defaultCalendar
            reminder.priority = 0
            
            do {
                try eventStore.save(reminder, commit: false)
                successCount += 1
            } catch {
                print("Error saving reminder: \(error)")
            }
        }
        
        // Commit all changes at once
        do {
            try eventStore.commit()
            alertMessage = "Successfully added \(successCount) items to Reminders!"
            showingAlert = true
        } catch {
            alertMessage = "Error saving reminders: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Grocery Item Row
struct GroceryItemRow: View {
    let item: String
    let isChecked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isChecked ? .green : .gray)
                
                Text(item)
                    .font(.body)
                    .foregroundColor(isChecked ? .secondary : .primary)
                    .strikethrough(isChecked)
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recipe Row View
struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 16) {
            // Placeholder for recipe image
            AsyncRecipeImage(imageName: recipe.recipe_image)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.recipe_name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("By \(recipe.recipe_author)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "cart")
                        .font(.caption2)
                    Text("\(recipe.shopping_list.count) ingredients")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Async Image Loader
struct AsyncRecipeImage: View {
    let imageName: String
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ZStack {
                    Color.gray.opacity(0.1)
                    ProgressView()
                }
            } else {
                ZStack {
                    Color.gray.opacity(0.1)
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        do {
            let loadedImage = try await RecipeImageLoader.shared.loadImage(named: imageName)
            await MainActor.run {
                self.image = loadedImage
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}

// MARK: - Image Loader (Modern async version)
actor RecipeImageLoader {
    static let shared = RecipeImageLoader()
    private var cache: [String: UIImage] = [:]
    
    func loadImage(named imageName: String) async throws -> UIImage {
        // Check cache first
        if let cached = cache[imageName] {
            return cached
        }
        
        let urlString = "https://pboc7upn8c.execute-api.us-east-1.amazonaws.com/s3downloaderapi?image=\(imageName).png"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.timeoutInterval = 10.0
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        cache[imageName] = image
        return image
    }
}

// MARK: - Recipe Detail View
struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @State private var hasAddedToGroceryList = false
    @State private var showingSuccessAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Image
                AsyncRecipeImage(imageName: recipe.recipe_image)
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Recipe Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.recipe_name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: "person.circle")
                            Text(recipe.recipe_author)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Shopping List Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Ingredients", systemImage: "cart")
                            .font(.headline)
                        
                        ForEach(recipe.shopping_list, id: \.self) { ingredient in
                            HStack(spacing: 12) {
                                Image(systemName: "circle")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text(ingredient)
                                    .font(.body)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Instructions Section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Instructions", systemImage: "book")
                            .font(.headline)
                        
                        Text(recipe.recipe_instructions)
                            .font(.body)
                            .lineSpacing(6)
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 80)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if !hasAddedToGroceryList {
                Button(action: addToGroceryList) {
                    Label("Add Ingredients to Grocery List", systemImage: "cart.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
                .background(Color(.systemBackground).shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5))
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Added to Grocery List")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 2)
                )
                .padding()
                .background(Color(.systemBackground).shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5))
            }
        }
        .alert("Success", isPresented: $showingSuccessAlert) {
            Button("View Grocery List", role: .none) {
                // Navigate to grocery list
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Ingredients added to your grocery list!")
        }
    }
    
    private func addToGroceryList() {
        withAnimation {
            // Add each ingredient as a separate line
            let newIngredients = recipe.shopping_list.joined(separator: "\n")
            
            if viewModel.groceryListString.isEmpty {
                viewModel.groceryListString = newIngredients
            } else {
                viewModel.groceryListString += "\n" + newIngredients
            }
            
            hasAddedToGroceryList = true
            
            // Show success feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
}

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension Binding where Value == Bool {
    
    static prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
        Binding<Bool>(
            get: { !value.wrappedValue },
            set: { value.wrappedValue = !$0 }
        )
    }
}
