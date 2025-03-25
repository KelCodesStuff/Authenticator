//
//  SetPasscodeView.swift
//  Authenticator
//
//  Created by Kel Reid on 2/6/24.
//  Copyright © 2024 OneVR LLC. All rights reserved.
//

import SwiftUI
import Combine
import KeychainSwift

struct SetPasscodeView: View {
    @Binding var passcode: String
    @Binding var isPasscodeSet: Bool
    @ObservedObject var biometricManager: BiometricManager
    
    @State private var confirmationPasscode = ""
    @State private var showPasscodeMismatchError = false
    
    @State private var isOverlayVisible = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Choose an eight digit passcode that will be used to encrypt and decrypt your data.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                // Input field for passcode
                SecureField("Passcode", text: $passcode)
                    .keyboardType(.numberPad)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(passcode.count == 8 ? Color.green : Color.red, lineWidth: 2))
                    .onChange(of: passcode) { newValue in
                        // Ensure passcode is trimmed to 8 characters if it exceeds the length
                        if newValue.count > 8 {
                            passcode = String(newValue.prefix(8))
                        }
                        // Check for passcode mismatch
                        checkForPasscodeMismatch()
                    }
                
                // Input field for confirming passcode
                SecureField("Confirm passcode", text: $confirmationPasscode)
                    .keyboardType(.numberPad)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(confirmationPasscode == passcode && confirmationPasscode.count == 8 ? Color.green : Color.red, lineWidth: 2))
                    .onChange(of: confirmationPasscode) { newValue in
                        // Ensure confirmation passcode is trimmed to 8 characters if it exceeds the length
                        if newValue.count > 8 {
                            confirmationPasscode = String(newValue.prefix(8))
                        }
                        // Check for passcode mismatch
                        checkForPasscodeMismatch()
                    }
                
                if biometricManager.isBiometricsAvailable() {
                    Toggle("Enable \(biometricManager.getBiometricType())", isOn: $biometricManager.isEnabled)
                        .padding()
                        .tint(.green)
                }
                
                Text("NOTICE:")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                Text("You must remember this passcode. We do not have access to your data and will not be able to restore your account.")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                
                // Display passcode mismatch error message if necessary
                if showPasscodeMismatchError {
                    Text("The passcodes you entered do not match.")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.top, 20)
                }
                
                Spacer()
            }
            .overlayViewLock(isVisible: $isOverlayVisible, showAlert: $showAlert)
            .padding()
            .navigationBarTitle("Set Passcode", displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                self.isOverlayVisible = true
                // Check if passcode and confirmation passcode match and are 8 digits long
                if passcode == confirmationPasscode && passcode.count == 8 {
                    // Save passcode to keychain and update passcode set flag
                    KeychainManager.shared.savePasscode(passcode)
                    isPasscodeSet = true
                } else if passcode.count != 8 {
                    // Display error message if passcode length is not 8 digits
                } else {
                    // Display error message if passcodes do not match
                }
            }) {
                Text("Start")
                    .fontWeight(.bold)
//                    .foregroundColor(.green)
            }
            // Disable button if passcode and confirmation passcode do not match or are not 8 digits long
            .disabled(!(passcode.count == 8 && passcode == confirmationPasscode)))
        }
    }
    
    // Function to check for passcode mismatch
    private func checkForPasscodeMismatch() {
        showPasscodeMismatchError = !passcode.isEmpty && !confirmationPasscode.isEmpty && passcode != confirmationPasscode
    }
}
