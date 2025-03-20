//
//  AuthenticatorUIScannerTests.swift
//  AuthenticatorUITests
//
//  Created by Kelvin Reid on 3/20/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest

final class AuthenticatorScannerTests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Check the environment variable *before* initializing the app.
        if !shouldRunUITests() {
            //  Skip all setup if UI tests are disabled.
            throw XCTSkip("Skipping UI tests due to RUN_UI_TESTS environment variable.")
        }
        
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
    func shouldRunUITests() -> Bool {
        guard let runUITests = ProcessInfo.processInfo.environment["RUN_UI_TESTS"] else {
            return false // Default to OFF if not set.
        }
        return runUITests.lowercased() == "true"
    }
    
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
        
        // Wait for 10 seconds
        sleep(10)
        
        // Navigate to add token screen
        let scanButton = app.buttons["qrcode"]
        XCTAssertTrue(scanButton.exists)
        scanButton.tap()
        
        // Check for the cancel button
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists)
/*
        These asserts are for actual devices
        // Wait for the scanner view to appear (up to 10 seconds)
        let scannerView = app.otherElements["AuthCodeScannerView"]
        let scannerViewExists = scannerView.waitForExistence(timeout: 10)
        XCTAssertTrue(scannerViewExists, "Scanner view did not appear within 10 seconds")
        
        //Check for the overlay.
        let qrCodeOverlay = app.otherElements["QRCodeOverlay"]
        XCTAssertTrue(qrCodeOverlay.exists)
*/
    }

}
