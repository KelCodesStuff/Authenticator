//
//  SettingsView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
import CloudKit

let container = CKContainer.default()
let privateDatabase = container.privateCloudDatabase

class DocumentPickerDelegate: NSObject, ObservableObject, UIDocumentPickerDelegate {
    @State private var isICloudBackupEnabled = false
    
    @Published var selectedURL: URL?

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        self.selectedURL = selectedURL
        controller.dismiss(animated: true, completion: nil)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

struct SettingsView: View {
    @Binding var isPresented: Bool
    @StateObject private var documentPickerDelegate = DocumentPickerDelegate()
    @StateObject private var biometricManager = BiometricManager()
    @State private var isICloudBackupEnabled = false
    @State private var showBiometricAlert = false
    @State private var showPasscodeVerification = false
    @State private var verificationPasscode = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @AppStorage("storedPasscode") private var storedPasscode: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Security"), footer: Text("Use \(biometricManager.getBiometricType()) to quickly unlock the app")) {
                    if biometricManager.isBiometricsAvailable() {
                        Toggle("\(biometricManager.getBiometricType())", isOn: Binding(
                            get: { biometricManager.isEnabled },
                            set: { newValue in
                                if newValue {
                                    showPasscodeVerification = true
                                } else {
                                    biometricManager.isEnabled = false
                                }
                            }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: Color.green))
                    }
                }
                
                Section(header: Text("Backup"), footer: Text("")) {
                    Toggle("iCloud Backup", isOn: $isICloudBackupEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        .onChange(of: isICloudBackupEnabled) { newValue, _ in
                            self.handleICloudBackupToggle(newValue)
                        }
                }
                
                Section(header: Text("Information"), footer: Text("")) {
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                       let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                        KeyValueRow("Version", value: "\(version) (\(build))")
                    } else {
                        KeyValueRow("Version", value: "")
                    }
                    
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/privacy-policy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundColor(Color.green)
                    }
                    
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/terms-of-service")!) {
                        Label("Terms of Service", systemImage: "note.text")
                            .foregroundColor(Color.green)
                    }
                    
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/end-user-license-agreement")!) {
                        Label("EULA", systemImage: "hand.thumbsup")
                            .foregroundColor(Color.green)
                    }
                }
                // MARK: - Test Button, Remove Before Release
                Button("Crash Test") {
                  fatalError("Crash was triggered")
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented.toggle()
            }
            .accentColor(Color.green))
        }
        .onAppear {
            self.checkICloudBackupStatus()
        }
        .alert("Biometric Authentication", isPresented: $showBiometricAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Biometric authentication is not available on this device.")
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
                }
            )
        }
    }

    private func verifyPasscodeAndEnableBiometrics() {
        KeychainManager.shared.retrievePasscode(verificationPasscode) { isSuccess in
            DispatchQueue.main.async {
                if isSuccess {
                    Task {
                        if await biometricManager.authenticate() {
                            biometricManager.isEnabled = true
                            showPasscodeVerification = false
                            verificationPasscode = ""
                        } else {
                            errorMessage = "Failed to enable \(biometricManager.getBiometricType()). Please try again."
                            showError = true
                            biometricManager.isEnabled = false
                        }
                    }
                } else {
                    errorMessage = "Incorrect passcode. Please try again."
                    showError = true
                    biometricManager.isEnabled = false
                }
            }
        }
    }

    // Helper view for key-value pairs
    private func KeyValueRow(_ key: String, value: String) -> some View {
        HStack {
            Text(key)
            Spacer()
            Text(value )
        }
    }
    
    // New function to handle iCloud backup toggle
    private func handleICloudBackupToggle(_ isEnabled: Bool) {
        if isEnabled {
            // Check iCloud availability and prompt if necessary
            CKContainer.default().accountStatus { (status, error) in
                DispatchQueue.main.async {
                    switch status {
                    case .available:
                        print("iCloud is available, proceed with enabling backup.")
                        // Proceed to enable backup functionality
                    default:
                        self.promptForICloudSettings()
                    }
                }
            }
        } else {
            // Handle disabling iCloud backup
            print("User has disabled iCloud backup.")
        }
    }
        
    private func checkICloudBackupStatus() {
        // Similar check as in handleICloudBackupToggle to initially set the toggle state
    }

    // Function to prompt user to enable iCloud in Settings
    private func promptForICloudSettings() {
//        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
//        if UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url, options: [:], completion: (() -> Void)? = nil)
//        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(false))
    }
}
