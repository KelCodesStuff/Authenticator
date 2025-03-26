import SwiftUI
import LocalAuthentication

struct BiometricVerificationSheet: View {
    @Binding var isPresented: Bool
    @Binding var verificationPasscode: String
    @Binding var biometricEnabled: Bool
    let biometricType: String
    let onCancel: () -> Void
    
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Verify your passcode to enable \(biometricType)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding([.leading, .bottom], 20)
                
                SecureField("Passcode", text: $verificationPasscode)
                    .keyboardType(.numberPad)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(verificationPasscode.count == 8 ? Color.green : Color.red, lineWidth: 2))
                    .onChange(of: verificationPasscode) { newValue in
                        if newValue.count > 8 {
                            verificationPasscode = String(newValue.prefix(8))
                        }
                    }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("FaceID", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    onCancel()
                }
                .foregroundColor(.red),
                trailing: Button(action: {
                    verifyPasscode()
                }) {
                    Text("Verify")
                        .foregroundColor(verificationPasscode.count == 8 ? .green : .gray)
                        .fontWeight(.bold)
                }
                .disabled(verificationPasscode.count != 8)
            )
            .accentColor(.green)
            .alert("Incorrect", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func verifyPasscode() {
        KeychainManager.shared.retrievePasscode(verificationPasscode) { isSuccess in
            DispatchQueue.main.async {
                if isSuccess {
                    Task {
                        let context = LAContext()
                        var error: NSError?
                        
                        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                            errorMessage = "Biometric authentication is not available."
                            showAlert = true
                            biometricEnabled = false
                            return
                        }
                        
                        do {
                            let success = try await context.evaluatePolicy(
                                .deviceOwnerAuthenticationWithBiometrics,
                                localizedReason: "Enable \(biometricType)"
                            )
                            if success {
                                biometricEnabled = true
                                isPresented = false
                                verificationPasscode = ""
                            } else {
                                errorMessage = "Failed to enable \(biometricType). Please try again."
                                showAlert = true
                                biometricEnabled = false
                            }
                        } catch {
                            errorMessage = "Failed to enable \(biometricType). Please try again."
                            showAlert = true
                            biometricEnabled = false
                        }
                    }
                } else {
                    errorMessage = "Incorrect passcode. Please try again."
                    showAlert = true
                    biometricEnabled = false
                }
            }
        }
    }
} 
