//
//  SettingsView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
import CoreData

/// Delegate class to handle document picker functionality
class DocumentPickerDelegate: NSObject, ObservableObject, UIDocumentPickerDelegate {
    @Published var selectedURL: URL?

    /// Called when user selects documents in picker
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        self.selectedURL = selectedURL
        controller.dismiss(animated: true, completion: nil)
    }

    /// Called when document picker is cancelled
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

/// Main settings view containing app configuration options
struct SettingsView: View {
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    @StateObject private var documentPickerDelegate = DocumentPickerDelegate()
    @StateObject private var biometricManager = BiometricManager()
    
    // State variables for various settings and UI controls
    @State private var showBiometricAlert = false
    @State private var showPasscodeVerification = false
    @State private var verificationPasscode = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showDisableConfirmation = false
    @State private var showChangePasscode = false
    @AppStorage("storedPasscode") private var storedPasscode: String = ""

    // MARK: - View Body
    var body: some View {
        NavigationView {
            Form {
                // Security & Privacy Section
                Section(header: Text("Security & Privacy")) {
                    if biometricManager.isBiometricsAvailable() {
                        Toggle(isOn: Binding(
                            get: { biometricManager.isEnabled },
                            set: { newValue in
                                if newValue {
                                    showPasscodeVerification = true
                                    AnalyticsService.shared.logEvent(.biometricEnabled)
                                } else {
                                    showDisableConfirmation = true
                                }
                            }
                        )) {
                            Label("Face ID / Touch ID", systemImage: "faceid")
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.green))
                    }
                    
                    Button(action: { showChangePasscode = true }) {
                        Label("Change Passcode", systemImage: "lock")
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                       let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        KeyValueRow("Version", value: "\(version) (\(build))", icon: "info.circle")
                    }
                    
                    Link(destination: URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID")!) {
                        Label("Rate App", systemImage: "star")
                    }
                }
                
                // Legal Section
                Section(header: Text("Legal")) {
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/privacy-policy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/terms-of-service")!) {
                        Label("Terms of Service", systemImage: "note.text")
                    }
                    
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/end-user-license-agreement")!) {
                        Label("EULA", systemImage: "hand.thumbsup")
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
        // View modifiers for handling various states and alerts
        .onAppear {
            AnalyticsService.shared.logEvent(.settingsOpened)
        }
        .alert("Biometric Authentication", isPresented: $showBiometricAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Biometric authentication is not available on this device.")
        }
        .alert("Disable \(biometricManager.getBiometricType())?", isPresented: $showDisableConfirmation) {
            Button("Cancel", role: .cancel) {
                biometricManager.isEnabled = true
            }
            Button("Disable", role: .destructive) {
                biometricManager.isEnabled = false
                AnalyticsService.shared.logEvent(.biometricDisabled)
            }
        } message: {
            Text("Are you sure you want to disable \(biometricManager.getBiometricType())? You'll need to use your passcode to unlock the app.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showPasscodeVerification) {
            BiometricVerificationSheet(
                isPresented: $showPasscodeVerification,
                verificationPasscode: $verificationPasscode,
                biometricEnabled: $biometricManager.isEnabled,
                biometricType: biometricManager.getBiometricType(),
                onCancel: {
                    showPasscodeVerification = false
                    biometricManager.isEnabled = false
                    verificationPasscode = ""
                    AnalyticsService.shared.logEvent(.biometricSetupCancelled)
                }
            )
        }
        .sheet(isPresented: $showChangePasscode) {
            ChangePasscodeView()
        }
    }

    // MARK: - Private Methods
    
    /// Verifies passcode and enables biometric authentication if successful
    private func verifyPasscodeAndEnableBiometrics() {
        KeychainManager.shared.retrievePasscode(verificationPasscode) { isSuccess in
            DispatchQueue.main.async {
                if isSuccess {
                    Task {
                        if await biometricManager.authenticate() {
                            biometricManager.isEnabled = true
                            showPasscodeVerification = false
                            verificationPasscode = ""
                            AnalyticsService.shared.logEvent(.biometricSetupCompleted)
                        } else {
                            errorMessage = "Failed to enable \(biometricManager.getBiometricType()). Please try again."
                            showError = true
                            biometricManager.isEnabled = false
                            AnalyticsService.shared.logEvent(.biometricSetupFailed)
                        }
                    }
                } else {
                    errorMessage = "Incorrect passcode. Please try again."
                    showError = true
                    biometricManager.isEnabled = false
                    AnalyticsService.shared.logEvent(.biometricSetupFailed)
                }
            }
        }
    }

    /// Helper view for displaying key-value pairs in settings
    private func KeyValueRow(_ key: String, value: String, icon: String? = nil) -> some View {
        HStack {
            if let icon = icon {
                Label(key, systemImage: icon)
            } else {
                Text(key)
            }
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
    }
}

/// Preview provider for SettingsView
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(false))
    }
}
