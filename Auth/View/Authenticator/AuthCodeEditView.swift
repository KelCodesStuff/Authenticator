//
//  AuthCodeEditView.swift
//  Auth
//
//  Created by Kelvin Reid on 2/7/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI

struct AuthCodeEditView: View {
    var token: Token
    var onDelete: () -> Void
    
    @Environment(\.presentationMode) var presentationMode // Access the presentation mode
    
    @State private var showingDeleteAlert = false
    @State private var secretVisible = false // State to manage secret
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Issuer")
                        Spacer()
                        Text(token.displayIssuer)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    HStack {
                        Text("Account Name")
                        Spacer()
                        Text(token.displayAccountName)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    // Assuming 'secret' is a sensitive piece of information, display it cautiously
                    HStack {
                        Text("Secret")
                        Spacer()
                        Text(secretVisible ? token.secret : "••••••••") // Show secret based on visibility state
                            .foregroundColor(.gray)
                            .onTapGesture {
                                toggleSecretVisibility()
                            }
                    }
                }
                
                Section {
                    Button("Delete Token") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            // Nav bar
            .navigationBarTitle("Token Settings", displayMode: .inline)
            
            // Delete alert
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete Token"),
                    message: Text("Are you sure you want to delete this token? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        onDelete()
                        presentationMode.wrappedValue.dismiss() // Dismiss the view
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func toggleSecretVisibility() {
        secretVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.secretVisible = false // Hide the secret after 10 seconds
        }
    }
}
