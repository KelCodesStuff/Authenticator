//
//  OTPTests.swift
//  AuthenticatorUnitTests
//
//  Created by Kel Reid on 3/15/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest
@testable import Authenticator

final class OTPTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - OTP Generation
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


