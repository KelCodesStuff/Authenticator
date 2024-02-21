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
    @State private var isICloudBackupEnabled = false


    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Backup"), footer: Text("")) {
                    Toggle("iCloud Backup", isOn: $isICloudBackupEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                            .onChange(of: isICloudBackupEnabled) { newValue in
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
    }

    // Helper view for key-value pairs
    private func KeyValueRow(_ key: String, value: String) -> some View {
        HStack {
            Text(key)
            Spacer()
            Text(value ?? "N/A")
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
