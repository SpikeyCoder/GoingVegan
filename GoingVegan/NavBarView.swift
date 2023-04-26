//
//  NavBarView.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/17/23.
//

import SwiftUI

struct NavBarView: View {
    var body: some View {
        AppTabView()
    }
}

struct NavBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavBarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct AppTabView : View {
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        return TabView {
            HomeScreenView(viewModel: AuthenticationViewModel())
                 .tabItem {
                     Label("Home", systemImage: "house")
                 }
                 .tag(0)
                 .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            RestaurantMapView()
                .tabItem {
                    Label("Eat Out", systemImage: "fork.knife")
                }
                .tag(1)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            
             RecipeListView()
                 .tabItem {
                     Label("Cook At Home", systemImage: "list.dash")
                 }
                 .tag(2)
                 .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                 .background(LinearGradient(gradient: Gradient(colors: [.gray, .gray]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all))
         }
    }
}
