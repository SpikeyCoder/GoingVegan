//
//  GoingVeganApp.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/9/23.
//

import SwiftUI

@main
struct GoingVeganApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
