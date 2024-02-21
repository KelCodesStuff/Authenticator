//
//  PasswordDetailView.swift
//  Auth
//
//  Created by Kelvin Reid on 2/7/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI

struct PasswordDetailView: View {
    var credential: Credential
    @State private var isPasswordRevealed: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Password for \(credential.website)")
                .font(.title2)
            
            if isPasswordRevealed {
                Text(credential.password) // Assuming 'password' is a property of Credential
                    .font(.title)
                    .foregroundColor(.blue)
                    .transition(.slide)
            } else {
                Text("••••••••")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            
            Button(action: { isPasswordRevealed.toggle() }) {
                Text(isPasswordRevealed ? "Hide Password" : "Show Password")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }
}
