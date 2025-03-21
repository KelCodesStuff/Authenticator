//
//  AuthenticatorScanTokenTests.swift
//  AuthenticatorUITests
//
//  Created by Kelvin Reid on 3/20/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest

final class AuthenticatorScanTokenTests: XCTestCase {

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
        // Only tear down if setup was actually performed
        if app != nil {
            app = nil
        }
    }
    
    // MARK: - Helper Methods
    private func unlockApp() throws {
        let app = XCUIApplication()
        
        // Check if SetPasscodeView is present
        if app.navigationBars["Set Passcode"].exists {
            // Set a passcode
            let passcodeField1 = app.secureTextFields["Passcode"]
            passcodeField1.tap()
            passcodeField1.typeText("12345678")
            
            let passcodeField2 = app.secureTextFields["Confirm passcode"]
            passcodeField2.tap()
            passcodeField2.typeText("12345678")
            
            app.buttons["Start"].tap()
        }
        
        // Input Passcode View
        let passcodeField = app.secureTextFields["Passcode"]
        passcodeField.tap()
        passcodeField.typeText("12345678")
        
        print(app.debugDescription) // Print UI hierarchy
        
        let unlockButton = app.buttons["Unlock"]
        
        // Extended wait with polling
        let startTime = Date()
        let timeout: TimeInterval = 20
        while !unlockButton.exists {
            if Date().timeIntervalSince(startTime) > timeout {
                // Take screenshot and UI hierarchy snapshot
                let screenshot = XCUIScreen.main.screenshot()
                let attachment = XCTAttachment(screenshot: screenshot)
                attachment.name = "UnlockButtonFailureScreenshot"
                attachment.lifetime = .keepAlways
                add(attachment)
                
                let hierarchyData = app.debugDescription.data(using: .utf8)!
                let hierarchyAttachment = XCTAttachment(data: hierarchyData, uniformTypeIdentifier: "public.plain-text")
                hierarchyAttachment.name = "UnlockButtonFailureHierarchy"
                hierarchyAttachment.lifetime = .keepAlways
                add(hierarchyAttachment)
                
                XCTFail("Unlock button did not appear after \(timeout) seconds")
                return
            }
            sleep(1)
        }
        
        unlockButton.tap()
    }
    
    // MARK: - Scanner Tests
    func testScannerView() throws {
        try unlockApp()
        
        // Wait for the QR code button to be available and tap it
        let scanButton = app.buttons["qrCodeButton"]
        let scanButtonExists = scanButton.waitForExistence(timeout: 5)
        XCTAssertTrue(scanButtonExists, "QR Code button should exist")
        scanButton.tap()
        
        // Verify scanner view is shown
        XCTAssertTrue(app.navigationBars["Scan QR Code"].exists)
/*
        #if targetEnvironment(simulator)
        // Simulator-specific checks
        // Verify the scanner view is present but camera is not available
        let scannerView = app.otherElements["CodeScannerView"]
        let scannerViewExists = scannerView.waitForExistence(timeout: 15)
        XCTAssertTrue(scannerViewExists, "Scanner view should be present in simulator")
        
        #else
        // Device-specific checks
        let scannerView = app.otherElements["CodeScannerView"]
        let scannerViewExists = scannerView.waitForExistence(timeout: 15)
        XCTAssertTrue(scannerViewExists, "Scanner view should appear on device")
        
        let qrCodeOverlay = app.otherElements["QRCodeOverlay"]
        XCTAssertTrue(qrCodeOverlay.exists, "QR code overlay should exist on device")
        #endif
        
        // Check for the cancel button
        let cancelButton = app.buttons["Cancel"]
        let cancelButtonExists = cancelButton.waitForExistence(timeout: 15)
        XCTAssertTrue(cancelButtonExists, "Cancel button should exist")
        
        // Close the scanner
        cancelButton.tap()
        
        // Verify we're back on the main view
        XCTAssertTrue(app.navigationBars["Authenticator"].exists)
 */
    }

}
