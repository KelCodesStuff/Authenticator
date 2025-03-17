//
//  AuthApp.swift
//  Auth
//
//  Created by Kelvin Reid on 2/7/24.
//

import SwiftUI
import Sentry


@main
struct AuthApp: App {
    
    init() {
        SentrySDK.start { options in
            options.dsn = "https://196034a60eb9c41750057225f5032566@o4506628563927040.ingest.sentry.io/4506633247326208"
            options.debug = true // Enabled debug when first installing is always helpful
            options.enableTracing = true 

            // Uncomment the following lines to add more data to your events
            // options.attachScreenshot = true // This adds a screenshot to the error events
            // options.attachViewHierarchy = true // This adds the view hierarchy to the error events
        }
        // Remove the next line after confirming that your Sentry integration is working.
        SentrySDK.capture(message: "This Auth app uses Sentry! :)")
        
        // Call the test function here
        testHashFunction()
    }
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LockScreenView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
