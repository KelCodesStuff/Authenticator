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
                Section(header: Text("Actions"), footer: Text("")) {
                    Button(action: {
                        // Handle the import action from files
                        self.importAction()
                    }) {
                        Label("Import", systemImage: "square.and.arrow.down")
                            .foregroundColor(Color.green)
                    }
                    Button(action: {
                        // Handle the export action to files
                        self.exportAction()
                    }) {
                        Label("Export", systemImage: "square.and.arrow.up")
                            .foregroundColor(Color.green)
                    }
                }
                Section(header: Text("Backup"), footer: Text("")) {
                    Toggle("iCloud Backup", isOn: $isICloudBackupEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                            .onChange(of: isICloudBackupEnabled) { newValue in
                                // Handle the state change, for example, triggering iCloud backup
                                if newValue {
//                                    self.iCloudBackupEnabled(account: )
                                } else {
//                                    self.iCloudBackupDisabled(account: )
                                }
                            }
                }
                Section(header: Text("Information"), footer: Text("")) {
                    KeyValueRow("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
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
    }

    // Helper view for key-value pairs
    private func KeyValueRow(_ key: String, value: String) -> some View {
        HStack {
            Text(key)
            Spacer()
            Text(value ?? "N/A")
        }
    }
    
    // Function to enable iCloud backup
    func iCloudBackupEnabled(account: Account) {
        // Implement the logic to start iCloud backup if needed
        // This might involve cancelling ongoing operations or removing backup-related data
        print("Starting iCloud backup...")
    }

    // Function to disable iCloud backup
    func iCloudBackupDisabled(account: Account) {
        // Implement the logic to stop iCloud backup if needed
        // This might involve cancelling ongoing operations or removing backup-related data
        print("Stopping iCloud backup...")
    }
    
    // Function to handle the import action
    private func importAction() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeCommaSeparatedText)], in: .import)
        documentPicker.delegate = documentPickerDelegate
        UIApplication.shared.windows.first?.rootViewController?.presentedViewController?.present(documentPicker, animated: true, completion: nil)
    }

    // Function to handle the export
    private func exportAction() {
        // Implement the logic for exporting data to a file
        // You can present a file picker or perform the necessary actions here
    }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(false))
    }
}
