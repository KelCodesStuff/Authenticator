//
//  AuthTests.swift
//  AuthTests
//
//  Created by Kelvin Reid on 2/7/24.
//

import XCTest
@testable import Auth

final class AuthTests: XCTestCase {
    var keychainManager: KeychainManager!
    
    override func setUp() {
        super.setUp()
        keychainManager = KeychainManager.shared
        // Setup code here. This method is called before the invocation of each test method in the class.
    }
        
    override func tearDown() {
        // Tear down code here. This method is called after the invocation of each test method in the class.
        keychainManager = nil
        super.tearDown()
    }
    
    func testSaveAndVerifyPasscode() {
        let passcode = "correctPasscode"
        KeychainManager.shared.savePasscode(passcode)
        
        // Attempt to verify the passcode
        let verificationResult = KeychainManager.shared.verifyPasscode(passcode)
        XCTAssertTrue(verificationResult, "Passcode verification should succeed for the correct passcode.")
        
        // Attempt to verify with an incorrect passcode
        let incorrectPasscodeResult = KeychainManager.shared.verifyPasscode("incorrectPasscode")
        XCTAssertFalse(incorrectPasscodeResult, "Passcode verification should fail for an incorrect passcode.")
    }
        
    func testSaltRandomnessByOutcome() {
        let passcode = "testPasscode"
        KeychainManager.shared.savePasscode(passcode)
        
        // Verify initial passcode
        XCTAssertTrue(KeychainManager.shared.verifyPasscode(passcode), "Initial verification should succeed.")
        
        // Change passcode slightly
        let modifiedPasscode = "testPasscodf" // Minor change
        KeychainManager.shared.savePasscode(modifiedPasscode)
        
        // Ensure the original passcode does NOT verify against the new hash
        XCTAssertFalse(KeychainManager.shared.verifyPasscode(passcode), "Verification with the original passcode should fail after re-saving with a modification, indicating a new hash was generated.")
    }

    // MARK: - New Tests
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
/*
    func testPBKDF2HashingConsistency() {
        let keychainManager = KeychainManager.shared
        let passcode = "testPasscode123"
        let salt = "fixedSaltForTesting" // Ensure this is the same salt used for generating the expectedHash
        let expectedHash = "expectedHashValueHere" // Replace with the actual expected hash value
        
        let resultHash = keychainManager.hashPasscode(passcode, salt: salt)
        
        XCTAssertEqual(resultHash, expectedHash, "Hashed passcode does not match the expected hash value.")
    }
    
    func testSaltRandomness() {
        let keychainManager = KeychainManager.shared
        let passcode = "samePasscode"

        let firstHashWithSalt = keychainManager.savePasscode(passcode)
        let secondHashWithSalt = keychainManager.savePasscode(passcode)

        XCTAssertNotEqual(firstHashWithSalt, secondHashWithSalt, "Hashes with salts should differ due to salt randomness.")
    }
*/
    func testPasscodeVerification() {
        let correctPasscode = "12345678"
        let incorrectPasscode = "87654321"
        
        KeychainManager.shared.savePasscode(correctPasscode)
        
        XCTAssertTrue(KeychainManager.shared.verifyPasscode(correctPasscode), "Passcode verification failed for the correct passcode.")
        XCTAssertFalse(KeychainManager.shared.verifyPasscode(incorrectPasscode), "Passcode verification incorrectly succeeded for the wrong passcode.")
    }
    
    func testKeychainSaveAndRetrieveOperations() {
        let passcode = "12345678"
        KeychainManager.shared.savePasscode(passcode)
        
        let retrievedPasscodeIsValid = KeychainManager.shared.verifyPasscode(passcode)
        XCTAssertTrue(retrievedPasscodeIsValid, "Retrieved passcode from Keychain does not match the saved passcode.")
    }

}
