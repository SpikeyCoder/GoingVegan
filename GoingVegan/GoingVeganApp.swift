//
//  GoingVeganApp.swift
//  GoingVegan
//
//  Created by Kevin Armstrong on 1/9/23.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth
import GoogleSignIn
import Foundation


@main
struct GoingVeganApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let persistenceController = PersistenceController.shared
    
    init() {
        setupAuthentication()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

extension GoingVeganApp {
    private func setupAuthentication() {
        FirebaseApp.configure()
      }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}
