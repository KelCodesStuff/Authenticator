//
//  PerformanceTests.swift
//  AuthenticatorPerformanceTests
//
//  Created by Kelvin Reid on 3/15/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest
@testable import Authenticator

final class PerformanceTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - TOTP Generation Performance Tests
    func testTOTPGenerationPerformance() throws {
        let validSecret = "JBSWY3DPEHPK3PXP"
        measure {
            for _ in 1...100 {
                _ = OTPGenerator.totp(secret: validSecret)
            }
        }
    }
    
    func testTOTPWithSHA256Performance() throws {
        let validSecret = "JBSWY3DPEHPK3PXP"
        measure {
            for _ in 1...100 {
                _ = OTPGenerator.totp(secret: validSecret, algorithm: .sha256)
            }
        }
    }
    
    func testTOTPWithSHA512Performance() throws {
        let validSecret = "JBSWY3DPEHPK3PXP"
        measure {
            for _ in 1...100 {
                _ = OTPGenerator.totp(secret: validSecret, algorithm: .sha512)
            }
        }
    }
    
    // MARK: - Token Operations Performance Tests
    
    func testTokenCreationPerformance() throws {
        let uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Test&algorithm=SHA1&digits=6&period=30"
        measure {
            for _ in 1...100 {
                _ = Token(uri: uri)
            }
        }
    }
    
    // MARK: - CPU Performance Tests
    func testTOTPGenerationCPUPerformance() throws {
        let validSecret = "JBSWY3DPEHPK3PXP"
        measure(metrics: [XCTCPUMetric()]) {
            for _ in 1...100 {
                _ = OTPGenerator.totp(secret: validSecret)
            }
        }
    }
    
    func testTokenCreationCPUPerformance() throws {
        let uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Test&algorithm=SHA1&digits=6&period=30"
        measure(metrics: [XCTCPUMetric()]) {
            for _ in 1...100 {
                _ = Token(uri: uri)
            }
        }
    }
    
    // MARK: - Memory Performance Tests
    
    func testTOTPGenerationMemoryPerformance() throws {
        let validSecret = "JBSWY3DPEHPK3PXP"
        measure(metrics: [XCTMemoryMetric()]) {
            for _ in 1...100 {
                _ = OTPGenerator.totp(secret: validSecret)
            }
        }
    }
    
    func testTokenCreationMemoryPerformance() throws {
        let uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Test&algorithm=SHA1&digits=6&period=30"
        measure(metrics: [XCTMemoryMetric()]) {
            for _ in 1...100 {
                _ = Token(uri: uri)
            }
        }
    }
    
    // MARK: - Clock Performance Tests
    func testTOTPGenerationClockPerformance() throws {
        let validSecret = "JBSWY3DPEHPK3PXP"
        measure(metrics: [XCTClockMetric()]) {
            for _ in 1...100 {
                _ = OTPGenerator.totp(secret: validSecret)
            }
        }
    }
    
    func testTokenCreationClockPerformance() throws {
        let uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Test&algorithm=SHA1&digits=6&period=30"
        measure(metrics: [XCTClockMetric()]) {
            for _ in 1...100 {
                _ = Token(uri: uri)
            }
        }
    }
    
    // MARK: - Comprehensive Performance Test
    func testComprehensivePerformance() throws {
        let validSecret = "JBSWY3DPEHPK3PXP"
        measure(metrics: [
            XCTClockMetric(),
            XCTCPUMetric(),
            XCTMemoryMetric()
        ]) {
            for _ in 1...100 {
                // Generate TOTP codes with different configurations
                _ = OTPGenerator.totp(secret: validSecret)
                _ = OTPGenerator.totp(secret: validSecret, algorithm: .sha256)
                _ = OTPGenerator.totp(secret: validSecret, algorithm: .sha512)
                _ = OTPGenerator.totp(secret: validSecret, digits: 8)
                
                // Create tokens from URI
                let uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Test&algorithm=SHA1&digits=6&period=30"
                _ = Token(uri: uri)
            }
        }
    }
} 
