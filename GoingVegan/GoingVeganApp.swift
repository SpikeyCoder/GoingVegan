//
//  GoingVeganApp.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/9/23.
//

import SwiftUI

@main
struct GoingVeganApp: App {
    @State var isLoggedIn: Bool = false
    
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                AppTabView()
                //HomeScreenView()
            }
            else {
                LoginView(isLoggedIn: $isLoggedIn)
                    //.environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            
                
        }
    }
}

