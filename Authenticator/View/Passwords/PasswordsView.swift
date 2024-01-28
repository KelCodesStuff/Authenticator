//
//  PasswordsView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 1/27/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI

struct PasswordsView: View {
    @State private var credentials: [Credential] = KeychainManager.shared.loadCredentials()
    @State private var showingDetail = false

    var body: some View {
        NavigationView {
            List {
                ForEach(credentials) { credential in
                    PasswordCardView(credential: credential)
                }
                .onDelete(perform: delete)
            }
            .navigationBarTitle("Passwords", displayMode: .inline)
            .navigationBarItems(trailing: addButton)
            .sheet(isPresented: $showingDetail) {
                AddPasswordView(credentials: $credentials, isNewCredential: true)
            }
        }
        .onAppear {
            self.credentials = KeychainManager.shared.loadCredentials()
        }
    }

    private var addButton: some View {
        Button(action: {
            showingDetail = true
        }) {
            Image(systemName: "plus")
        }
    }

    func delete(at offsets: IndexSet) {
        credentials.remove(atOffsets: offsets)
        KeychainManager.shared.saveCredentials(credentials)
    }
}

#Preview {
    PasswordsView()
}
