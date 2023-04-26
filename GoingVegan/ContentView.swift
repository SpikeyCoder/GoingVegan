//
//  ContentView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 2/22/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel = AuthenticationViewModel()
    
    var body: some View {
        if viewModel.state == .signedIn {
            TabView {
                HomeScreenView(viewModel: self.viewModel)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .environmentObject(viewModel)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                RestaurantMapView()
                    .tabItem {
                        Label("Eat Out", systemImage: "fork.knife")
                    }
                    .environmentObject(viewModel)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                RecipeListView()
                    .tabItem {
                        Label("Cook At Home", systemImage: "frying.pan")
                    }
                    .environmentObject(viewModel)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
        }
        else {
            LoginView()
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
