//
//  PasswordsView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 1/27/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI
import KeychainSwift

struct PasswordsView: View {
    @State private var credentials: [Credential] = KeychainManager.shared.loadCredentials()
    @State private var showingDetail = false
    @State private var isSheetPresented: Bool = false
    @State private var editingCredential: Credential?

    var body: some View {
        NavigationView {
            List {
                ForEach(credentials) { credential in
                    PasswordCardView(credential: credential)

                }
            }
            .navigationBarTitle("Passwords", displayMode: .inline)
            .navigationBarItems(leading: settingsButton, trailing: addButton)
            
            .sheet(isPresented: $showingDetail, onDismiss: {
                            editingCredential = nil // Reset the editing credential when the sheet is dismissed
                        }) {
                            AddPasswordView(credentials: $credentials)
                        }
            .sheet(isPresented: $isSheetPresented) {
                switch presentingSheet {
                case .showSettings:
                    SettingsView(isPresented: $isSheetPresented)
                }
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            presentingSheet = .showSettings
            isSheetPresented = true
        }) {
            Image(systemName: "gear")
        }
    }
    
    private var addButton: some View {
        Button(action: {
            editingCredential = nil // Reset the editing credential
            showingDetail = true
        }) {
            Image(systemName: "plus")
        }
    }
}

private var presentingSheet: SheetSet = .showSettings
private var tokenIndex: Int = 0

private enum SheetSet {
        case showSettings
}

#Preview {
    PasswordsView()
}
