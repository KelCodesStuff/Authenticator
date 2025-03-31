//
//  TokenEditView.swift
//  Auth
//
//  Created by Kel Reid on 2/7/24.
//  Copyright © 2024 OneVR LLC. All rights reserved.
//

import SwiftUI

/// A view that allows users to edit token details and manage token deletion
/// This view is presented as a sheet when editing a token from the main view
struct TokenEditView: View {
    // MARK: - Properties
    
    /// The token being edited
    var token: Token
    /// Callback executed when the token is deleted
    var onDelete: () -> Void
    /// Callback executed when the token is saved with new values
    var onSave: (String, String) -> Void
    
    // MARK: - Environment
    
    /// Environment variable to control the presentation mode of this view
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    /// Controls visibility of the delete confirmation alert
    @State private var showingDeleteAlert = false
    /// Controls visibility of the token's secret
    @State private var secretVisible = false
    /// The edited issuer name
    @State private var editedIssuer: String
    /// The edited account name
    @State private var editedAccountName: String
    /// Controls visibility of the discard changes alert
    @State private var showingDiscardAlert = false
    /// Controls visibility of the validation alert
    @State private var showingValidationAlert = false
    
    // MARK: - Initialization
    
    /// Initializes a new TokenEditView
    /// - Parameters:
    ///   - token: The token to edit
    ///   - onDelete: Callback executed when the token is deleted
    ///   - onSave: Callback executed when the token is saved with new values
    init(token: Token, onDelete: @escaping () -> Void, onSave: @escaping (String, String) -> Void) {
        self.token = token
        self.onDelete = onDelete
        self.onSave = onSave
        
        // Initialize state variables with current values
        _editedIssuer = State(initialValue: token.displayIssuer)
        _editedAccountName = State(initialValue: token.displayAccountName)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                // Token Details Section
                Section {
                    // Issuer field - editable
                    HStack {
                        Text("Issuer")
                        Spacer()
                        TextField("Issuer", text: $editedIssuer)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.primary)
                    }
                    
                    // Account Name field - editable
                    HStack {
                        Text("Account Name")
                        Spacer()
                        TextField("Account Name", text: $editedAccountName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.primary)
                    }
                    
                    // Secret field - read-only with visibility toggle
                    HStack {
                        Text("Secret")
                        Spacer()
                        Text(secretVisible ? token.secret : "••••••••")
                            .foregroundColor(.gray)
                            .onTapGesture {
                                toggleSecretVisibility()
                            }
                    }
                }
                
                // Actions Section
                Section {
                    // Delete button
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Text("Delete 2FA Token")
                    }
                }
            }
            .navigationBarTitle("Edit 2FA Token: \(token.displayIssuer)", displayMode: .inline)
            .navigationBarItems(
                // Cancel button - shows discard alert if there are changes
                leading: Button("Cancel") {
                    if hasChanges {
                        showingDiscardAlert = true
                    } else {
                        dismissView()
                    }
                }
                .foregroundColor(.red),
                // Save button - saves changes and dismisses view
                trailing: Button("Save") {
                    validateAndSave()
                }
                .foregroundColor(.green)
                .fontWeight(.bold)
            )
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismissView()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this account? You will not be able to use this device to verify your identity.")
            }
            .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Cancel", role: .cancel) {
                    showingDiscardAlert = false
                }
            } message: {
                Text("Are you sure you want to discard your changes?")
            }
            .alert("Save Error", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Issuer and Account Name cannot be empty.")
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Dismisses the view using the dismiss environment value
    private func dismissView() {
        dismiss()
    }
    
    /// Checks if the user has made any changes to the token
    private var hasChanges: Bool {
        editedIssuer != token.displayIssuer || editedAccountName != token.displayAccountName
    }
    
    /// Saves the edited token values and logs the edit event
    private func validateAndSave() {
        let trimmedIssuer = editedIssuer.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAccountName = editedAccountName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedIssuer.isEmpty || trimmedAccountName.isEmpty {
            showingValidationAlert = true
            return
        }
        
        // Log the edit event
        AnalyticsService.shared.logEvent(.tokenEdited)
        // Call the save callback with the edited values
        onSave(trimmedIssuer, trimmedAccountName)
        dismiss()
    }
    
    /// Toggles the visibility of the token's secret
    /// Shows the secret for 10 seconds before hiding it again
    private func toggleSecretVisibility() {
        secretVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.secretVisible = false
        }
    }
}
