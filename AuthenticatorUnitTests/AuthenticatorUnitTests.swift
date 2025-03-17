//
//  AuthenticatorUnitTests.swift
//  AuthenticatorUnitTests
//
//  Created by Kelvin Reid on 3/15/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest
@testable import Authenticator

final class AuthenticatorUnitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Token Tests
    func testValidTokenCreation() throws {
        // Test valid TOTP URI
        let validUri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Test&algorithm=SHA1&digits=6&period=30"
        let token = Token(uri: validUri)
        
        XCTAssertNotNil(token, "Token should be created with valid URI")
        XCTAssertEqual(token?.type, .totp)
        XCTAssertEqual(token?.issuer, "Test")
        XCTAssertEqual(token?.displayIssuer, "Test")
        XCTAssertEqual(token?.accountName, "user@example.com")
        XCTAssertEqual(token?.secret, "JBSWY3DPEHPK3PXP")
        XCTAssertEqual(token?.algorithm, .sha1)
        XCTAssertEqual(token?.digits, 6)
        XCTAssertEqual(token?.period, 30)
    }
    
    func testInvalidTokenCreation() throws {
        // Test invalid URI scheme
        let invalidSchemeUri = "invalid://totp/Test:user@example.com?secret=JBSWY111PEHPK3PXP"
        XCTAssertNil(Token(uri: invalidSchemeUri), "Token should not be created with invalid scheme")
        
        // Test invalid host
        let invalidHostUri = "otpauth://invalid/Test:user@example.com?secret=JBSWY3DPEHPK3PXP"
        XCTAssertNil(Token(uri: invalidHostUri), "Token should not be created with invalid host")
        
        // Test missing secret
        let missingSecretUri = "otpauth://totp/Test:user@example.com"
        XCTAssertNil(Token(uri: missingSecretUri), "Token should not be created without secret")
        
        // Test invalid secret (containing non-Base32 characters)
        let invalidSecretUri = "otpauth://totp/Test:user@example.com?secret=!@#$%^&*()"
        XCTAssertNil(Token(uri: invalidSecretUri), "Token should not be created with non-Base32 secret")
        
    }
    
    func testTokenParameters() throws {
        // Test different algorithm parameters
        let sha256Uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA256"
        XCTAssertEqual(Token(uri: sha256Uri)?.algorithm, .sha256)
        
        let sha512Uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA512"
        XCTAssertEqual(Token(uri: sha512Uri)?.algorithm, .sha512)
        
        // Test different digit lengths
        let digits7Uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&digits=7"
        XCTAssertEqual(Token(uri: digits7Uri)?.digits, 7)
        
        let digits8Uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&digits=8"
        XCTAssertEqual(Token(uri: digits8Uri)?.digits, 8)
        
        // Test different periods
        let period60Uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&period=60"
        XCTAssertEqual(Token(uri: period60Uri)?.period, 60)
    }
    
    func testTokenDisplay() throws {
        // Test issuer and account name display
        let uri = "otpauth://totp/Issuer:account@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Issuer"
        let token = Token(uri: uri)
        
        XCTAssertEqual(token?.displayIssuer, "Issuer")
        XCTAssertEqual(token?.displayAccountName, "account@example.com")
        
        // Test fallback display values
        let minimalUri = "otpauth://totp/?secret=JBSWY3DPEHPK3PXP"
        let minimalToken = Token(uri: minimalUri)
        
        XCTAssertEqual(minimalToken?.displayIssuer, "")
        XCTAssertEqual(minimalToken?.displayAccountName, "")
    }

    // MARK: - OTP Tests
    func testTOTPGeneration() throws {
        // Test valid secret
        let validSecret = "JBSWY3DPEHPK3PXP"
        let totp = OTPGenerator.totp(secret: validSecret)
        XCTAssertNotNil(totp, "TOTP should be generated for valid secret")
        XCTAssertEqual(totp?.count, 6, "TOTP should be 6 digits by default")
        XCTAssert(totp?.allSatisfy { $0.isNumber } ?? false, "TOTP should only contain numbers")
        
        // Test different digit lengths
        let totp7 = OTPGenerator.totp(secret: validSecret, digits: 7)
        XCTAssertEqual(totp7?.count, 7, "TOTP should be 7 digits when specified")
        
        let totp8 = OTPGenerator.totp(secret: validSecret, digits: 8)
        XCTAssertEqual(totp8?.count, 8, "TOTP should be 8 digits when specified")
        
        // Test different algorithms
        XCTAssertNotNil(OTPGenerator.totp(secret: validSecret, algorithm: .sha1), "TOTP should work with SHA1")
        XCTAssertNotNil(OTPGenerator.totp(secret: validSecret, algorithm: .sha256), "TOTP should work with SHA256")
        XCTAssertNotNil(OTPGenerator.totp(secret: validSecret, algorithm: .sha512), "TOTP should work with SHA512")
        
        // Test code consistency within time period
        let firstCode = OTPGenerator.totp(secret: validSecret)
        let secondCode = OTPGenerator.totp(secret: validSecret)
        XCTAssertEqual(firstCode, secondCode, "TOTP should be consistent within the same time period")
    }
}
