//
//  ContentView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 4/6/23.
//

import SwiftUI
import CryptoKit
import CoreData

struct ContentView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var loggedIn = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Authenticator")
                    .font(.largeTitle)
                    .padding()

                TextField("Username", text: $username)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))

                NavigationLink(destination: GenerateCodeView(), isActive: $loggedIn) {
                    Button(action: { 
                        self.loggedIn = true
                    }) {
                        Text("Login")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

