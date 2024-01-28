//
//  PasswordGeneratorView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI

struct PasswordGeneratorView: View {
    @State var password = ""
    @State var passwordLength = 8
    @State var includeSpecialCharacters = true
    @State var includeNumbers = true
    @State var isCopied = false
    @State private var isSheetPresented: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    Text(password)
                        .font(.largeTitle.monospacedDigit())
                        .padding()
                        .frame(maxWidth: .infinity)
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
                // MARK: - Nav bar
                .navigationBarTitle("Passwords", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {
                        presentingSheet = .showSettings
                        isSheetPresented = true
                    }) {
                        Image(systemName: "gear")
                        },
                    trailing: Button(action: {
                        // Add action for the second button
                        // For example, you can perform some action when the second button is tapped
                    }) {
                        Image(systemName: "plus")
                        }
                )
            }
            .sheet(isPresented: $isSheetPresented) {
                switch presentingSheet {
                case .showSettings:
                    SettingsView(isPresented: $isSheetPresented)
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

private var presentingSheet: SheetSet = .showSettings
private var tokenIndex: Int = 0

private enum SheetSet {
        case showSettings
}

struct PasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordsView()
    }
}
