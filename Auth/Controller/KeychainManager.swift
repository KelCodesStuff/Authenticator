//
//  KeychainManager.swift
//  Authenticator
//
//  Created by Kelvin Reid on 1/27/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import Foundation
import KeychainSwift
import CryptoKit
import CryptoSwift

class KeychainManager {
    static let shared = KeychainManager()
    
    private let keychain = KeychainSwift()
    private let credentialsKey = "credentials"

    // Function to save passcode
    func savePasscode(_ passcode: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let salt = self.generateSalt()
            guard let hashedPasscode = self.hashPasscode(passcode, salt: salt) else {
                DispatchQueue.main.async {
                    print("Error hashing passcode")
                }
                return
            }
            let combined = "\(salt)#\(hashedPasscode)" // Using '#' as a delimiter
            
            if let data = combined.data(using: .utf8) {
                do {
                    try self.keychain.set(data, forKey: self.credentialsKey)
                    DispatchQueue.main.async {
                        print("Saving Salt: \(salt), Hashed Passcode: \(hashedPasscode)")
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("Error saving passcode to keychain: \(error)")
                    }
                }
            }
        }
    }
        
    // Function to retrieve passcode
    func retrievePasscode(_ inputPasscode: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = self.keychain.getData(self.credentialsKey),
                  let combined = String(data: data, encoding: .utf8),
                  let delimiterIndex = combined.firstIndex(of: "#") else {
                DispatchQueue.main.async {
                    print("Failed to retrieve or decode passcode data from keychain.")
                    completion(false)
                }
                return
            }
            
            let salt = String(combined[..<delimiterIndex])
            let savedHashedPasscode = String(combined[combined.index(after: delimiterIndex)...])
            
            guard let inputHashedPasscode = self.hashPasscode(inputPasscode, salt: salt) else {
                DispatchQueue.main.async {
                    print("Error hashing input passcode.")
                    completion(false)
                }
                return
            }
            
            let result = (savedHashedPasscode == inputHashedPasscode)
            DispatchQueue.main.async {
                print("Retrieving Salt: \(salt), Input Hashed: \(inputHashedPasscode), Saved Hashed: \(savedHashedPasscode)")
                completion(result)
            }
        }
    }
        
        // Function to hash passcode using PBKDF2
        func hashPasscode(_ passcode: String, salt: String) -> String? {
            guard let passcodeData = passcode.data(using: .utf8),
                  let saltData = Data(base64Encoded: salt) else {
                return nil
            }
            
            let keyLength = 32 // 32 bytes = 256 bits
            let rounds = 5000 // Adjust based on performance
            
            do {
                let derivedKey = try PKCS5.PBKDF2(password: passcodeData.bytes,
                                                  salt: saltData.bytes,
                                                  iterations: rounds,
                                                  keyLength: keyLength,
                                                  variant: .sha256).calculate()
                
                return derivedKey.toHexString()
            } catch {
                print("Error deriving key: \(error)")
                return nil
            }
        }
    
    // Function to salt passcode
    func generateSalt() -> String {
        let salt = Data((0..<32).map { _ in UInt8.random(in: UInt8.min...UInt8.max) })
        return salt.base64EncodedString()
    }
    
    func saveCredentials(_ credentials: [Credential]) {
        if let data = try? JSONEncoder().encode(credentials) {
            keychain.set(data, forKey: credentialsKey)
        }
    }

    func loadCredentials() -> [Credential] {
        if let data = keychain.getData(credentialsKey),
           let credentials = try? JSONDecoder().decode([Credential].self, from: data) {
            return credentials
        }
        return []
    }
}

func testHashFunction() {
    let keychainManager = KeychainManager.shared
    let testPasscode = "12345678" // Example passcode
    let testSalt = keychainManager.generateSalt()
    let hashedPasscode = keychainManager.hashPasscode(testPasscode, salt: testSalt)
    
    print("Test Passcode: \(testPasscode), Test Salt: \(testSalt), Hashed: \(hashedPasscode)")
}
