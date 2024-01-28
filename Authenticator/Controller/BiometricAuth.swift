//
//  BiometricAuth.swift
//  Authenticator
//
//  Created by Kelvin Reid on 1/28/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import LocalAuthentication

class BiometricAuth {
    static func authenticate(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access your passwords") { success, authenticationError in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            // Possibly handle devices without biometric authentication
        }
    }
}
