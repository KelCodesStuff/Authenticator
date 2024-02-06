//
//  KeychainManager.swift
//  Authenticator
//
//  Created by Kelvin Reid on 1/27/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import KeychainSwift
import Foundation
import CryptoKit

class KeychainManager {
    static let shared = KeychainManager()
    private let keychain = KeychainSwift()

    private let credentialsKey = "credentials"

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
