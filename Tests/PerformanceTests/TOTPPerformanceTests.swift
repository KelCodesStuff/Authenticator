//
//  TOTPPerformanceTests.swift
//  AuthenticatorPerformanceTests
//
//  Created by Kel Reid on 3/15/25.
//

import XCTest
@testable import Authenticator

final class TOTPPerformanceTests: XCTestCase {
    
    // MARK: - TOTP Generation (Wall Clock)
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
    
    // MARK: - CPU Performance
    func testTOTPGenerationCPUPerformance() throws {
        let validSecret = "JBSWY3DPEHPK3PXP"
        measure(metrics: [XCTCPUMetric()]) {
            for _ in 1...100 {
                _ = OTPGenerator.totp(secret: validSecret)
            }
        }
    }
    
    // MARK: - Memory Performance
    func testTOTPGenerationMemoryPerformance() throws {
        let validSecret = "JBSWY3DPEHPK3PXP"
        measure(metrics: [XCTMemoryMetric()]) {
            for _ in 1...100 {
                _ = OTPGenerator.totp(secret: validSecret)
            }
        }
    }
    
    // MARK: - Clock Performance
    func testTOTPGenerationClockPerformance() throws {
        let validSecret = "JBSWY3DPEHPK3PXP"
        measure(metrics: [XCTClockMetric()]) {
            for _ in 1...100 {
                _ = OTPGenerator.totp(secret: validSecret)
            }
        }
    }
}


