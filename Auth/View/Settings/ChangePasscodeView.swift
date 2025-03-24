//  ChangePasscodeView.swift
//  Authenticator
//
//  Created by Kel Reid on 03/24/25
//
import SwiftUI
import Combine

struct ChangePasscodeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPasscode = ""
    @State private var newPasscode = ""
    @State private var confirmPasscode = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var isOverlayVisible = false
    @State private var showPasscodeMismatchError = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Instructions for changing passcode
                Text("Enter your current passcode and choose a new eight digit passcode.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding([.leading, .bottom], 20)
                
                // Current passcode field
                SecureField("Current Passcode", text: $currentPasscode)
                    .keyboardType(.numberPad)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(currentPasscode.count == 8 ? Color.green : Color.red, lineWidth: 2))
                    .onChange(of: currentPasscode) { newValue in
                        if newValue.count > 8 {
                            currentPasscode = String(newValue.prefix(8))
                        }
                    }
                
                // New passcode field
                SecureField("New Passcode", text: $newPasscode)
                    .keyboardType(.numberPad)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(newPasscode.count == 8 ? Color.green : Color.red, lineWidth: 2))
                    .onChange(of: newPasscode) { newValue in
                        if newValue.count > 8 {
                            newPasscode = String(newValue.prefix(8))
                        }
                        checkForPasscodeMismatch()
                    }
                
                // Confirm new passcode field
                SecureField("Confirm New Passcode", text: $confirmPasscode)
                    .keyboardType(.numberPad)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(confirmPasscode == newPasscode && confirmPasscode.count == 8 ? Color.green : Color.red, lineWidth: 2))
                    .onChange(of: confirmPasscode) { newValue in
                        if newValue.count > 8 {
                            confirmPasscode = String(newValue.prefix(8))
                        }
                        checkForPasscodeMismatch()
                    }
                
                if showPasscodeMismatchError {
                    Text("The new passcodes you entered do not match.")
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding([.leading, .top], 20)
                }
                
                Spacer()
            }
            .overlayViewLock(isVisible: $isOverlayVisible)
            .padding()
            .navigationBarTitle("Change Passcode", displayMode: .large)
            .navigationBarItems(trailing: Button(action: {
                self.isOverlayVisible = true
                changePasscode()
            }) {
                Text("Save")
                    .fontWeight(.bold)
            }
            .disabled(!(currentPasscode.count == 8 && newPasscode.count == 8 && confirmPasscode.count == 8 && newPasscode == confirmPasscode)))
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Passcode has been changed successfully.")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func checkForPasscodeMismatch() {
        showPasscodeMismatchError = !newPasscode.isEmpty && !confirmPasscode.isEmpty && newPasscode != confirmPasscode
    }
    
    private func changePasscode() {
        // Verify current passcode
        KeychainManager.shared.retrievePasscode(currentPasscode) { isSuccess in
            DispatchQueue.main.async {
                if isSuccess {
                    // Save new passcode
                    KeychainManager.shared.savePasscode(newPasscode)
                    showSuccess = true
                } else {
                    errorMessage = "Current passcode is incorrect"
                    showError = true
                }
                isOverlayVisible = false
            }
        }
    }
}

struct ChangePasscodeView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasscodeView()
    }
} 
