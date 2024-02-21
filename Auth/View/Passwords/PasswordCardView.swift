//
//  PasswordCardView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 1/27/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI
import Foundation

struct PasswordCardView: View {
    @State var credential: Credential // This should ideally be @Binding if the Credential is passed from a parent view
    
    @State private var isEditViewPresented: Bool = false
    @State private var isPasswordViewPresented: Bool = false

    private let diameter: CGFloat = 32

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 16) {
                Text(credential.website)
                    .font(.headline)
                
                Spacer()
                
                Button(action: { isEditViewPresented = true }) {
                    Image(systemName: "pencil")
                        .frame(width: diameter, height: diameter)
//                        .foregroundColor(.blue)
//                        .background(Circle().fill(Color.gray.opacity(0.2)))
                }
                .sheet(isPresented: $isEditViewPresented) {
                    EditPasswordView(credential: $credential)
                }
            }
            
            HStack {
                Text(credential.username)
                    .font(.headline.monospacedDigit())
                Spacer()
            }
        }
        .padding()

    }
}

