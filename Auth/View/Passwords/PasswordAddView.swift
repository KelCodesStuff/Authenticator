//
//  AddPasswordView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 1/27/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI
import KeychainSwift

struct AddPasswordView: View {
    @Binding var credentials: [Credential]
    var credentialToEdit: Credential?
    
    @Environment(\.presentationMode) var presentationMode // Access the presentation mode
    
    @State private var website = ""
    @State private var username = ""
    @State private var password = ""
    @State private var showingErrorAlert = false // State to control error alert visibility

    // The error message to be displayed in the alert
    @State private var errorMessage = ""

    var isNewCredential: Bool {
        credentialToEdit == nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Website")) {
                    TextField("Website", text: $website)
                        .onChange(of: website) { newValue in
                            let lowercaseValue = newValue.lowercased()
                            if !lowercaseValue.hasPrefix("http://") && !lowercaseValue.hasPrefix("https://") {
                                website = "https://" + lowercaseValue
                            } else {
                                website = lowercaseValue
                            }
                        }
                }
                Section(header: Text("Username")) {
                    TextField("Username", text: $username)
                }
                Section(header: Text("Password")) {
                    SecureField("Password", text: $password)
                }
            }
            .navigationBarTitle(isNewCredential ? "Add Password" : "Edit Password", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save") {
                saveCredential()
            })
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            if let credential = credentialToEdit {
                website = credential.website
                username = credential.username
                password = credential.password
            }
        }
    }

    private func saveCredential() {
        guard !website.isEmpty, !username.isEmpty, !password.isEmpty else {
            errorMessage = "All fields are required."
            showingErrorAlert = true
            return
        }
        
        if let editingCredential = credentialToEdit {
            // Find and update existing credential
            if let index = credentials.firstIndex(where: { $0.id == editingCredential.id }) {
                credentials[index].website = website
                credentials[index].username = username
                credentials[index].password = password
            }
        } else {
            // Add new credential
            let newCredential = Credential(website: website, username: username, password: password)
            credentials.append(newCredential)
        }
        
        KeychainManager.shared.saveCredentials(credentials)
        clearForm()
        presentationMode.wrappedValue.dismiss() // Dismiss the view here
    }

    private func clearForm() {
        website = ""
        username = ""
        password = ""
    }
}
