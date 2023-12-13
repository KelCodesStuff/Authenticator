//
//  SettingsView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General"), footer: Text("")) {
                    KeyValueRow("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                    Link(destination: URL(string: "https://github.com/kelcodesstuff/authenticator-iOS")!) {
                        Label("Source Code", systemImage: "chevron.left.slash.chevron.right")
                            .foregroundColor(Color.green)
                    }
                }
                Section(header: Text("Passwords"), footer: Text("")) {
                    Button(action: {
                        // Handle the import action from files
                        // You can present a file picker or perform the necessary actions here
                    }) {
                        Label("Import", systemImage: "square.and.arrow.down")
                            .foregroundColor(Color.green)
                    }
                    Button(action: {
                        // Handle the exmport action from files
                        // You can present a file picker or perform the necessary actions here
                    }) {
                        Label("Export", systemImage: "square.and.arrow.up")
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
            Text(value)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(false))
    }
}
