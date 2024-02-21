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
    
    @State private var passcode: String = ""
    @State private var isUnlocked = false
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        if isUnlocked {
            ContentView()
        } else {
            if isPasscodeSet {
                InputPasscodeView(passcode: $passcode, isUnlocked: $isUnlocked, showAlert: $showAlert, errorMessage: $errorMessage, storedPasscode: storedPasscode)
            } else {
                SetPasscodeView(passcode: $passcode, isPasscodeSet: $isPasscodeSet)
            }
        }
    }
}


