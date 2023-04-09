//
//  AppDelegate.swift
//  authenticator-ios
//
//  Created by Kelvin Reid on 4/8/23.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure FirebaseApp
        FirebaseApp.configure()
        
        return true
    }
}
