//
//  PasswordsView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI

struct PasswordsView: View {
    @State var password = ""
    @State var passwordLength = 8
    @State var includeSpecialCharacters = true
    @State var includeNumbers = true
    @State var isCopied = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Text(password)
                        .font(.largeTitle.monospacedDigit())
                        .padding()
                        .frame(maxWidth: .infinity)
//                        .border(Color.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(4)
                        .padding(.horizontal)
                        .onTapGesture {
                            UIPasteboard.general.string = password
                            isCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isCopied = false
                            }
                        }
                    
                        .overlay(
                            Text("Generate a Password")
                            .font(.callout)
                            .foregroundColor(.gray)
                            .opacity(password.isEmpty ? 0.6 : 0)
                        )
/*
                        if isCopied {
                            Text("Password Copied")
                            .foregroundColor(.green)
                            .padding()
                            .cornerRadius(10)
                            .transition(.opacity)
                            .font(.footnote)
                            .animation(.easeInOut)
                        }
*/
                    Spacer()
                    
                    HStack {
                        Spacer()
                        // Password length stepper
                        Text("Password Length: \(passwordLength)")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .font(.footnote)
                        
                        Spacer()
                        Stepper(
                            value: $passwordLength,
                            in: 8...32,
                            label: {
                                EmptyView()
                            }
                        )
                    }
                    
                    // Special characters toggle
                    Toggle("Include Special Characters", isOn: $includeSpecialCharacters)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 25)
                        .font(.footnote)
                    
                    // Numbers toggle
                    Toggle("Include Numbers", isOn: $includeNumbers)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 25)
                        .font(.footnote)
                    
                    Button(action: {
                        password = generatePassword()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                                .foregroundColor(.green)
                    }
                    .padding(.bottom, 100)
                    
                    // Tab bar color
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 5)
                        .background(Color.gray.opacity(0.3))
                }
            }
        }
    }
    
    // Generate password function
    func generatePassword() -> String {
        var letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        if includeSpecialCharacters {
            letters += "!@#$%^&*()_-+="
        }
        if includeNumbers {
            letters += "0123456789"
        }
        return String((0..<passwordLength).compactMap { _ in letters.randomElement() })
    }
}

struct PasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordsView()
    }
}
