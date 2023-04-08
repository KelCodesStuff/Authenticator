//
//  authenticator_iosApp.swift
//  authenticator-ios
//
//  Created by Kelvin Reid on 4/7/23.
//

import SwiftUI

@main
struct authenticator_iosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
