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
    @State private var service = ""
    @State private var username = ""
    @State private var password = ""
    var isNewCredential: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("")) {
                    TextField("Website", text: $service)
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
                let newCredential = Credential(service: service, username: username, password: password)
                if isNewCredential {
                    credentials.append(newCredential)
                } else {
                    // Handle updating an existing credential
                }
                KeychainManager.shared.saveCredentials(credentials)
                service = ""
                username = ""
                password = ""
            })
        }
    }
}


