//
//  PasswordsView.swift
//  authenticator-ios
//
//  Created by Kelvin Reid on 4/22/23.
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
            VStack {
                Text("Password:")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                Text(password)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .border(Color.gray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .padding(.horizontal)
                    
                
                Button(action: {
                    UIPasteboard.general.string = password
                    isCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isCopied = false
                    }
                }) {
                    Text("Copy Password")
                        .font(.footnote)
                        .padding()
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .padding(.vertical, 10)

                if isCopied {
                    Text("Password copied to clipboard")
                        .foregroundColor(.green)
                        .padding()
                  //      .background(Color.green)
                        .cornerRadius(10)
                        .transition(.opacity)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text("Password Length: \(passwordLength)")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        
                    Spacer()
                    Stepper(
                        value: $passwordLength,
                        in: 8...32,
                        label: {
                            EmptyView()
                        }
                    )
                }
                
                Toggle("Include Special Characters", isOn: $includeSpecialCharacters)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 25)
                
                Toggle("Include Numbers", isOn: $includeNumbers)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 25)
                
                Button(action: {
                    password = generatePassword()
                }) {
                    Text("New Password")
                        .font(.footnote)
                        .padding()
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom, 100)
            }
        }
    }
    
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
