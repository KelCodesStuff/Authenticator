//
//  LoginView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 4/6/23.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loggedIn = false
    @State private var errorMessage = ""
    @State private var showingSignUp = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: { self.showingSignUp = true }) {
                        Text("Sign Up")
                            .font(.system(size: 14))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()

                Text("Authenticator")
                    .font(.largeTitle)
                    .padding()

                TextField("Username", text: $email)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))

                Button(action: login) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                    } else {
                        Text("Login")
                            .padding(.horizontal, 50)
                            .padding(.vertical, 10)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading)
                .onAppear(perform: { isLoading = false })
                
                // Display error message in alert
                .alert(isPresented: Binding<Bool>(
                    get: { !errorMessage.isEmpty },
                    set: { _ in errorMessage = "" }
                ), content: {
                    Alert(
                        title: Text("Error"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                })
            }
            .padding()
            .blur(radius: isLoading ? 3 : 0) // Blur the screen while loading
        }
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .fullScreenCover(isPresented: $loggedIn) {
            GenerateCodeView()
        }
    }

    func login() {
        isLoading = true // Start the spinner
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                // There was an error logging in
                errorMessage = error.localizedDescription
            } else {
                // Successfully logged in
                loggedIn = true
            }
            
            isLoading = false // Stop the spinner
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
