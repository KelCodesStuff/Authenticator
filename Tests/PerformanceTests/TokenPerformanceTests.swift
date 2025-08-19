//
//  TokenPerformanceTests.swift
//  AuthenticatorPerformanceTests
//
//  Created by Kel Reid on 3/15/25.
//

import XCTest
@testable import Authenticator

final class TokenPerformanceTests: XCTestCase {

    // MARK: - Token Operations (Wall Clock)
    func testTokenCreationPerformance() throws {
        let uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Test&algorithm=SHA1&digits=6&period=30"
        measure {
            for _ in 1...100 {
                _ = Token(uri: uri)
            }
        }
    }

    // MARK: - CPU Performance
    func testTokenCreationCPUPerformance() throws {
        let uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Test&algorithm=SHA1&digits=6&period=30"
        measure(metrics: [XCTCPUMetric()]) {
            for _ in 1...100 {
                _ = Token(uri: uri)
            }
        }
    }

    // MARK: - Memory Performance
    func testTokenCreationMemoryPerformance() throws {
        let uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Test&algorithm=SHA1&digits=6&period=30"
        measure(metrics: [XCTMemoryMetric()]) {
            for _ in 1...100 {
                _ = Token(uri: uri)
            }
        }
    }

    // MARK: - Clock Performance
    func testTokenCreationClockPerformance() throws {
        let uri = "otpauth://totp/Test:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Test&algorithm=SHA1&digits=6&period=30"
        measure(metrics: [XCTClockMetric()]) {
            for _ in 1...100 {
                _ = Token(uri: uri)
            }
        }
    }
}


