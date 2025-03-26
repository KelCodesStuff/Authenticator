//
//  BackUpItem.swift
//  Authenticator
//
//  Created by Kel Reid on 2/9/24.
//  Copyright © 2024 OneVR LLC. All rights reserved.
//

import Foundation
import CloudKit
import CryptoKit
import Security

struct BackUpItem: Codable {
    // Authenticator
    let accountName: String
    let issuer: String
    let secretKey: String
    
    // Passwords
    let website: String
    let username: String
    let password: String
}

struct BackUpData: Codable {
    var items: [BackUpItem]
}

func generateSymmetricKey() -> SymmetricKey {
    return SymmetricKey(size: .bits256)
}

func encryptBackUpData(backUpData: Data, using key: SymmetricKey) -> Data? {
    do {
        let sealedBox = try AES.GCM.seal(backUpData, using: key)
        return sealedBox.combined
    } catch {
        print("Encryption error: \(error)")
        return nil
    }
}

func serializeBackupData(backUpData: BackUpData) -> Data? {
    do {
        let jsonData = try JSONEncoder().encode(backUpData)
        return jsonData
    } catch {
        print("Serialization error: \(error)")
        return nil
    }
}

func encryptSymmetricKey(_ key: SymmetricKey, with userPublicKey: SecKey) -> Data? {
    let keyData = Data(key.withUnsafeBytes { Array($0) })
    
    var error: Unmanaged<CFError>?
    guard let encryptedKey = SecKeyCreateEncryptedData(userPublicKey, .rsaEncryptionOAEPSHA256AESGCM, keyData as CFData, &error) else {
        print("Key encryption error: \(String(describing: error))")
        return nil
    }
    return encryptedKey as Data
}

func decryptSymmetricKey(_ encryptedKey: Data, with userPrivateKey: SecKey) -> SymmetricKey? {
    var error: Unmanaged<CFError>?
    guard let decryptedKeyData = SecKeyCreateDecryptedData(userPrivateKey, .rsaEncryptionOAEPSHA256AESGCM, encryptedKey as CFData, &error) else {
        print("Key decryption error: \(String(describing: error))")
        return nil
    }
    return SymmetricKey(data: decryptedKeyData as Data)
}

// Function to save to iCloud
func saveEncryptedBackUpToiCloud(encryptedData: Data, encryptedKey: Data) {
    let privateDatabase = CKContainer.default().privateCloudDatabase
    let backupRecord = CKRecord(recordType: "AuthenticatorBackup")
    backupRecord["encryptedData"] = encryptedData
    backupRecord["encryptedKey"] = encryptedKey
    
    privateDatabase.save(backupRecord) { record, error in
        if let error = error {
            print("Error saving to iCloud: \(error)")
        } else {
            print("Backup saved successfully to iCloud")
        }
    }
}

// Function to retreive from iCloud
func restoreBackUpFromiCloud() {
    let privateDatabase = CKContainer.default().privateCloudDatabase
    let query = CKQuery(recordType: "AuthenticatorBackup", predicate: NSPredicate(value: true))
    
    privateDatabase.perform(query, inZoneWith: nil) { records, error in
        if let error = error {
            print("Error fetching backups from iCloud: \(error)")
        } else if let records = records, let backupRecord = records.first {
            guard let encryptedData = backupRecord["encryptedData"] as? Data,
                  let encryptedKey = backupRecord["encryptedKey"] as? Data else {
                print("Error: Backup data format is incorrect")
                return
            }
            // Proceed to decrypt the encryptedKey and encryptedData
        }
    }
}
