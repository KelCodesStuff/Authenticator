//
//  ManualTokenEntryView.swift
//  Authenticator
//
//  Created by Kel Reid on 03/21/25
//

import SwiftUI
import SwiftOTP

/// A view that allows manual entry of TOTP token details
struct ManualTokenEntryView: View {
    // MARK: - Properties
    
    /// Binding to control presentation of this view
    @Binding var isPresented: Bool
    
    /// Completion handler called when token is added successfully or fails
    let completion: (Result<String, CodeScannerView.ScanError>) -> Void
    
    // MARK: - State Properties
    
    /// Token issuer name (e.g. "Google", "Microsoft")
    @State private var issuer = ""
    
    /// Account name/identifier (e.g. "user@example.com") 
    @State private var accountName = ""
    
    /// Secret key in base32 format
    @State private var secret = ""
    
    /// Controls visibility of error alert
    @State private var showErrorAlert = false
    
    /// Error message to display in alert
    @State private var errorMessage = ""
    
    /// Selected hash algorithm for token generation
    @State private var selectedAlgorithm: OTPAlgorithm = .sha256
    
    /// Number of digits in generated token
    @State private var selectedDigits: Int = 6
    
    /// Controls visibility of algorithm help alert
    @State private var showAlgorithmHelp = false
    
    // MARK: - Focus Management
    
    /// Tracks which text field is currently focused
    @FocusState private var focusedField: Field?
    
    /// Enum defining focusable fields
    private enum Field {
        case issuer, accountName, secret
    }
    
    // MARK: - Computed Properties
    
    /// Returns true if all required fields have values
    private var allFieldsFilled: Bool {
        !issuer.isEmpty && !accountName.isEmpty && !secret.isEmpty
    }
    
    /// Converts selected algorithm enum to string representation
    private var algorithmString: String {
        switch selectedAlgorithm {
        case .sha256:
            return "SHA256"
        case .sha512:
            return "SHA512"
        case .sha1:
            return "SHA1"
        }
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            Form {
                // Token details section
                Section(header: Text("Token Details")) {
                    TextField("Issuer", text: $issuer)
                        .textContentType(.organizationName)
                        .focused($focusedField, equals: .issuer)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .accountName
                        }
                    
                    TextField("Account Name", text: $accountName)
                        .textContentType(.username)
                        .focused($focusedField, equals: .accountName)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .secret
                        }
                    
                    SecureField("Secret Key", text: $secret)
                        .textContentType(.oneTimeCode)
                        .focused($focusedField, equals: .secret)
                        .submitLabel(.done)
                        .onSubmit {
                            addToken()
                        }
                }
                
                // Advanced options section
                Section(header: 
                    HStack {
                        Text("Advanced Options")
                        Spacer()
                        Button(action: {
                            showAlgorithmHelp = true
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                ) {
                    Picker("Algorithm", selection: $selectedAlgorithm) {
                        Text("SHA256").tag(OTPAlgorithm.sha256)
                        Text("SHA512").tag(OTPAlgorithm.sha512)
                    }
                    
                    Picker("Code Length", selection: $selectedDigits) {
                        Text("6 digits").tag(6)
                        Text("8 digits").tag(8)
                    }
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addToken()
                    }
                    .disabled(!allFieldsFilled)
                    .foregroundColor(allFieldsFilled ? .green : .gray)
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .alert("Algorithm Information", isPresented: $showAlgorithmHelp) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("""
                    SHA256: Most commonly used algorithm. Provides good security and is widely supported.
                    
                    SHA512: More secure but less commonly supported. Use only if your service specifically requires it.
                    
                    Note: Most services use SHA256 by default.
                    """)
            }
            .onAppear {
                focusedField = .issuer
            }
        }
    }
    
    // MARK: - Validation Methods
    
    /// Validates the issuer name
    /// - Returns: True if valid, false otherwise
    private func validateIssuer() -> Bool {
        if issuer.isEmpty || issuer.count > 50 {
            errorMessage = "Issuer must be between 1 and 50 characters"
            showErrorAlert = true
            return false
        }
        return true
    }
    
    /// Validates the account name
    /// - Returns: True if valid, false otherwise
    private func validateAccountName() -> Bool {
        if accountName.isEmpty || accountName.count > 50 {
            errorMessage = "Account name must be between 1 and 50 characters"
            showErrorAlert = true
            return false
        }
        return true
    }
    
    /// Validates the secret key
    /// - Returns: True if valid, false otherwise
    private func validateSecret() -> Bool {
        // Remove any spaces from the secret
        secret = secret.replacingOccurrences(of: " ", with: "")
        
        // Check if the secret is valid base32
        let base32Regex = "^[A-Z2-7]+=*$"
        if secret.range(of: base32Regex, options: .regularExpression) == nil {
            errorMessage = "Secret key must be a valid base32 string."
            showErrorAlert = true
            return false
        }
        
        // Check minimum length
        if secret.count < 16 {
            errorMessage = "Secret key must be at least 16 characters"
            showErrorAlert = true
            return false
        }
        
        return true
    }
    
    // MARK: - Token Creation
    
    /// Validates input and creates a new token
    private func addToken() {
        // Validate all fields
        guard validateIssuer() && validateAccountName() && validateSecret() else {
            return
        }
        
        // Create a URI with the entered details
        let uri = "otpauth://totp/\(issuer):\(accountName)?secret=\(secret)&issuer=\(issuer)&algorithm=\(algorithmString)&digits=\(selectedDigits)"
        
        // Validate the token
        guard let token = Token(uri: uri) else {
            errorMessage = "Invalid token details. Please check your input."
            showErrorAlert = true
            return
        }
        
        // Complete with success
        completion(.success(uri))
        isPresented = false
    }
} 
