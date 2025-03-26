//
//  iCloudManager.swift
//  Authenticator
//
//  Created by Kel Reid on 2/9/24.
//  Copyright © 2024 OneVR LLC. All rights reserved.
//

import UIKit
import CloudKit

class iCloudManager {
    
    static let shared = iCloudManager()
    
    private init() {}
    
    func checkiCloudAvailability(completion: @escaping (Bool, Error?) -> Void) {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    completion(true, nil)
                case .noAccount, .restricted, .couldNotDetermine:
                    completion(false, error)
                @unknown default:
                    completion(false, NSError(domain: "com.Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown iCloud account status"]))
                }
            }
        }
    }
    
    func promptForiCloudLogin() {
        let alert = UIAlertController(title: "iCloud Account Required", message: "Please log in to your iCloud account to enable iCloud backups.", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        // Present the alert from your view controller
        // viewController.present(alert, animated: true)
    }
    
    func handleiCloudError(_ error: Error?) {
        var message = "An error occurred with iCloud. Please check your iCloud settings."
        if let error = error {
            message += "\nError: \(error.localizedDescription)"
        }
        
        let alert = UIAlertController(title: "iCloud Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        // Present the alert from your view controller
        // viewController.present(alert, animated: true)
    }
}
