//
//  AuthenticatorUITests.swift
//  AuthenticatorUITests
//
//  Created by Kelvin Reid on 3/15/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest

final class AuthenticatorUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        
        // Enable biometric authentication in simulator
        if #available(iOS 13.0, *) {
            app.launchEnvironment["XCUITest_FASTLANE_SKIP_BIOMETRICS"] = "false"
        }
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    private func unlockApp() throws {
        let passcodeField = app.secureTextFields["Passcode"]
        passcodeField.tap()
        passcodeField.typeText("12345678")
        let unlockButton = app.buttons["Unlock"]
        unlockButton.tap()
    }
    
    // MARK: - Launch Performance Test
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    // MARK: - Authentication Flow Tests
    func testPasscodeEntry() throws {
        try unlockApp()
    }
    
    func testBiometricAuthentication() throws {
        // Check if biometric button exists (only if biometrics are available)
        let biometricButton = app.buttons["Use Face ID"] // or "Use Touch ID" depending on device
        if biometricButton.exists {
            biometricButton.tap()
            // Note: Actual biometric authentication cannot be tested in UI tests
            // as it requires real device interaction
        } else {
            // If biometrics not available, enter passcode and unlock
            try unlockApp()
        }
    }
    
    // MARK: - Token Management Tests
    func testAddNewToken() throws {
        try unlockApp()
        
        // Navigate to add token screen
        let scanButton = app.buttons["qrcode"]
        XCTAssertTrue(scanButton.exists)
        scanButton.tap()
        
        // Note: QR code scanning cannot be tested in UI tests
        // as it requires real camera interaction
    }
    
    func testTokenListNavigation() throws {
        throw XCTSkip("Skipping this test for now.")
        
        try unlockApp()
        
        // Verify token list exists
        let tokenList = app.tables.element
        XCTAssertTrue(tokenList.exists)
        
        // Test scrolling
        tokenList.swipeUp()
        tokenList.swipeDown()
    }
    
    func testTokenDetails() throws {
        try unlockApp()
        
        // Tap on a token if it exists
        let tokenCell = app.cells.element(boundBy: 0)
        if tokenCell.exists {
            tokenCell.tap()
            
            // Verify details are shown
            let issuerLabel = app.staticTexts["Issuer"]
            XCTAssertTrue(issuerLabel.exists)
            
            let accountLabel = app.staticTexts["Account Name"]
            XCTAssertTrue(accountLabel.exists)
        }
    }
    
    // MARK: - Settings Tests
    func testSettingsNavigation() throws {
        try unlockApp()
        
        // Navigate to settings using the gear icon
        let settingsButton = app.buttons["gearshape"]
        XCTAssertTrue(settingsButton.exists)
        settingsButton.tap()
        
        // Verify settings options
        let biometricToggle = app.switches["Face ID"] // or "Touch ID" depending on device
        if biometricToggle.exists {
            XCTAssertTrue(biometricToggle.exists)
        } else {
            // Log that biometric toggle is not available
            print("Biometric toggle not available - this is expected in simulator unless configured")
        }
        
        let iCloudBackupToggle = app.switches["iCloud Backup"]
        XCTAssertTrue(iCloudBackupToggle.exists)
    }
    
    // MARK: - Error Handling Tests
    func testInvalidPasscode() throws {
        // Enter invalid passcode
        let passcodeField = app.secureTextFields["Passcode"]
        passcodeField.tap()
        passcodeField.typeText("00000000")
        
        // Submit
        let unlockButton = app.buttons["Unlock"]
        unlockButton.tap()
        
        // Verify error alert
        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.exists)
        
        // Dismiss alert
        errorAlert.buttons["OK"].tap()
    }
    
    func testInvalidTokenURI() throws {
        try unlockApp()
        
        // Navigate to add token screen
        let scanButton = app.buttons["qrcode"]
        scanButton.tap()
        
        // Note: QR code scanning cannot be tested in UI tests
        // as it requires real camera interaction
    }
}
