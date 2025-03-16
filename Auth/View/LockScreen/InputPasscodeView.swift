//
//  InputPasscodeView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 2/6/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI
import Combine
import KeychainSwift
import LocalAuthentication

struct InputPasscodeView: View {
    @Binding var passcode: String
    @Binding var isUnlocked: Bool
    @Binding var showAlert: Bool
    @Binding var errorMessage: String
    @ObservedObject var biometricManager: BiometricManager
    let storedPasscode: String
    
    @State private var isOverlayVisible = false
    @State private var showBiometricButton = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Welcome message
                Text("Welcome back, please enter your passcode.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding([.leading, .bottom], 20)
                
                // Secure passcode entry field
                SecureField("Passcode", text: $passcode)
                    .keyboardType(.numberPad)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(passcode.count == 8 ? Color.green : Color.red, lineWidth: 2))
                    .onReceive(Just(passcode)) { newValue in
                        // Sanitize input to allow only digits
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.passcode = filtered
                        }
                        // Trim passcode to 8 characters
                        if passcode.count > 8 {
                            passcode = String(passcode.prefix(8))
                        }
                    }
                
                if biometricManager.isEnabled {
                    Button(action: {
                        Task {
                            let success = await biometricManager.authenticate()
                            if success {
                                isUnlocked = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: biometricManager.getBiometricType() == "Face ID" ? "faceid" : "touchid")
                                .font(.title)
                            Text("Use \(biometricManager.getBiometricType())")
                        }
                        .foregroundColor(.green)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 1))
                    }
                    .padding(.top)
                }
                
                Spacer()
            }
            .overlayViewUnlock(isVisible: $isOverlayVisible)
            .padding()
            .navigationBarTitle("Authenticator 2FA+", displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                self.isOverlayVisible = true
                // Check if passcode is exactly 8 digits
                if passcode.count == 8 {
                    // Verify passcode using KeychainManager asynchronously
                    KeychainManager.shared.retrievePasscode(passcode) { isSuccess in
                        DispatchQueue.main.async {
                            if isSuccess {
                                // Update state to reflect successful unlock
                                isUnlocked = true
                            } else {
                                // Display error if passcode is incorrect
                                errorMessage = "Incorrect passcode. Please try again."
                                showAlert = true
                            }
                        }
                    }
                } else {
                    // Display error if passcode length is invalid
                }
            }) {
                Text("Unlock")
                    .fontWeight(.bold)
//                    .foregroundColor(.green)
            }
            // Disable button if passcode length is not 8 digits
            .disabled(!(passcode.count == 8)))
            
            // Display alert with error message if necessary
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
