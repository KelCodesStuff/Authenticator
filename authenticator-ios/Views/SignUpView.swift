//
//  SignUpView.swift
//  authenticator-ios
//
//  Created by Kelvin Reid on 4/8/23.
//

import SwiftUI
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var showingAlert = false

    var body: some View {
        VStack {
            HStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding()

                Spacer()

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                })
            }

            TextField("Email", text: $email)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))

            SecureField("Password", text: $password)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))

            Button(action: signUp) {
                Text("Sign Up")
                    .padding(.horizontal, 50)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
            }
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    func signUp() {
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            showingAlert = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                // There was an error signing up
                errorMessage = error.localizedDescription
                showingAlert = true
            } else {
                // Successfully signed up
                // You can handle this case here, e.g. by dismissing the view
            }
        }
    }
}
