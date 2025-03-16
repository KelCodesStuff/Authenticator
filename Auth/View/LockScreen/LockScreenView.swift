//
//  LockScreenView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 2/6/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI
import LocalAuthentication
import KeychainSwift
import Combine

struct LockScreenView: View {
    @AppStorage("isPasscodeSet") private var isPasscodeSet = false
    @AppStorage("storedPasscode") private var storedPasscode: String = ""
    
    @StateObject private var biometricManager = BiometricManager()
    @State private var passcode: String = ""
    @State private var isUnlocked = false
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        if isUnlocked {
            ContentView()
        } else {
            if isPasscodeSet {
                InputPasscodeView(
                    passcode: $passcode,
                    isUnlocked: $isUnlocked,
                    showAlert: $showAlert,
                    errorMessage: $errorMessage,
                    biometricManager: biometricManager,
                    storedPasscode: storedPasscode
                )
                .task {
                    if biometricManager.isEnabled {
                        let success = await biometricManager.authenticate()
                        if success {
                            isUnlocked = true
                        }
                    }
                }
            } else {
                SetPasscodeView(
                    passcode: $passcode,
                    isPasscodeSet: $isPasscodeSet,
                    biometricManager: biometricManager
                )
            }
        }
    }
}


