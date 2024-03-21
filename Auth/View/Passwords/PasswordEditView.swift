//
//  PasswordEditView.swift
//  Auth
//
//  Created by Kelvin Reid on 2/7/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI

struct PasswordEditView: View {
    @Binding var credential: Credential
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isFormValid = false
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    @State private var tempCredential: Credential
    
    // Initialize tempCredential with the value of credential
    init(credential: Binding<Credential>) {
        self._credential = credential
        // Create a temporary copy of credential for editing
        _tempCredential = State(initialValue: credential.wrappedValue)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("")) {
                    TextField("Website", text: $credential.website)
                }
                Section(header: Text("")) {
                    TextField("Username", text: $credential.username)
                }
                Section(header: Text("")) {
                    SecureField("Username", text: $credential.password)
                }
            }
            .navigationBarTitle("Edit Password", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                
                // Just dismiss without saving any changes
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                validateForm()
                if isFormValid {
                    // Apply changes from tempCredential to the actual credential before dismissing
                    credential = tempCredential
                    // Perform save operation here, if necessary
                    presentationMode.wrappedValue.dismiss()
                }
            })
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Password Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func validateForm() {
        if tempCredential.website.isEmpty || tempCredential.username.isEmpty || tempCredential.password.isEmpty {
            errorMessage = "All fields are required."
            showingErrorAlert = true
            isFormValid = false
        } else {
            // Add any additional validation logic here
            isFormValid = true
        }
    }
}
