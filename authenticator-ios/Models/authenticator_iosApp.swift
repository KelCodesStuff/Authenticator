//
//  authenticator_iosApp.swift
//  authenticator-ios
//
//  Created by Kelvin Reid on 4/7/23.
//

import SwiftUI
import Firebase

@main
struct authenticator_iosApp: App {
    init() {
        FirebaseApp.configure()
    }
    let persistenceController = PersistenceController.shared
    
    

    var body: some Scene {
        WindowGroup {
            
            LoginView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
