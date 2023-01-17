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
             HomeScreenView()
                 .tabItem {
                     Label("Home", systemImage: "house")
                 }
                 .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
             
             RecipeListView()
                 .tabItem {
                     Label("Recipe List", systemImage: "list.dash")
                 }
                 .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                 .background(LinearGradient(gradient: Gradient(colors: [.gray, .gray]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all))
         }
    }
}
