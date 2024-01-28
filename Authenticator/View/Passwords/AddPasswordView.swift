//
//  AddPasswordView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 1/27/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI

struct AddPasswordView: View {
    @Binding var credentials: [Credential]
    var credentialToEdit: Credential?
    var isNewCredential: Bool
    
    @State private var website = ""
    @State private var username = ""
    @State private var password = ""
    
    var editingCredential: Credential?
    
    init(credentials: Binding<[Credential]>, credentialToEdit: Credential? = nil) {
            self._credentials = credentials
            self.credentialToEdit = credentialToEdit
            self.isNewCredential = credentialToEdit == nil
        }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("")) {
                    TextField("Website", text: $website)
                }
                Section(header: Text("")) {
                    TextField("Username", text: $username)
                }
                Section(header: Text("")) {
                    SecureField("Password", text: $password)
                }
            }
            .navigationBarTitle(isNewCredential ? "Add Password" : "Edit Password", displayMode: .inline)
            .navigationBarItems(trailing: Button("Save") {
                guard !website.isEmpty, !username.isEmpty, !password.isEmpty else { return }
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
                website = ""
                username = ""
                password = ""
            })
        }
        .onAppear {
            if let credential = credentialToEdit {
                website = credential.website
                username = credential.username
                password = credential.password
            }
        }
    }
}
